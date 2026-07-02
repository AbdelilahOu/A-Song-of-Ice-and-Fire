<script lang="ts">
	import { client } from '$lib/orpc';
	import { displayName, lifespan } from '$lib/format';
	import { layoutTree, NODE_W, NODE_H, FRAME_W, FRAME_H } from '$lib/tree-layout';

	type Tree =
		| Awaited<ReturnType<typeof client.tree.byHouse>>
		| Awaited<ReturnType<typeof client.tree.byHouses>>
		| Awaited<ReturnType<typeof client.tree.all>>;

	type Props = {
		slugs: string[]; // empty = all houses
		selectionLabel: string;
		selectedMember: string | null;
		onSelect: (slug: string) => void;
	};
	let { slugs, selectionLabel, selectedMember, onSelect }: Props = $props();

	let tree = $state<Tree>(null);
	let loading = $state(true);

	$effect(() => {
		const selectedSlugs = slugs;
		loading = true;
		const req =
			selectedSlugs.length === 0
				? client.tree.all()
				: selectedSlugs.length === 1
					? client.tree.byHouse({ slug: selectedSlugs[0] })
					: client.tree.byHouses({ slugs: selectedSlugs });
		req
			.then((r) => {
				tree = r;
				loading = false;
			})
			.catch(() => {
				tree = null;
				loading = false;
			});
	});

	let layout = $derived(
		tree ? layoutTree(tree.nodes, tree.parentEdges, tree.marriageEdges) : null
	);

	let vw = $state(0);
	let vh = $state(0);
	let scale = $state(0.78);
	let tx = $state(40);
	let ty = $state(24);
	let canvasEl = $state<HTMLDivElement>();
	let dragging = false;
	let lastX = 0;
	let lastY = 0;
	let startX = 0;
	let startY = 0;
	let captured = false;
	let lastCentered: string | null = null;

	const DRAG_THRESHOLD = 5;

	const pointers = new Map<number, { x: number; y: number }>();
	let pinchDist = 0;
	let pinchMidX = 0;
	let pinchMidY = 0;

	const clampScale = (s: number) => Math.min(1.8, Math.max(0.3, s));

	function zoomAt(next: number, clientX: number, clientY: number) {
		if (!canvasEl) return;
		const rect = canvasEl.getBoundingClientRect();
		const cx = clientX - rect.left;
		const cy = clientY - rect.top;
		const worldX = (cx - tx) / scale;
		const worldY = (cy - ty) / scale;
		tx = cx - worldX * next;
		ty = cy - worldY * next;
		scale = next;
	}

	$effect(() => {
		const key = slugs.length ? slugs.join('|') : '__all__';
		if (layout && vw && lastCentered !== key) {
			scale = Math.min(0.85, Math.max(0.35, (vw - 80) / layout.width));
			tx = Math.max(20, (vw - layout.width * scale) / 2);
			ty = 30;
			lastCentered = key;
		}
	});

	function pinch() {
		const [a, b] = [...pointers.values()];
		return {
			dist: Math.hypot(a.x - b.x, a.y - b.y),
			midX: (a.x + b.x) / 2,
			midY: (a.y + b.y) / 2
		};
	}

	function onpointerdown(e: PointerEvent) {
		pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
		if (pointers.size === 1) {
			// Defer pointer capture until the pointer actually moves. Capturing on
			// press steals the native click from the node buttons, which breaks
			// tap-to-open on desktop.
			dragging = true;
			captured = false;
			startX = lastX = e.clientX;
			startY = lastY = e.clientY;
		} else if (pointers.size === 2) {
			dragging = false;
			(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
			const p = pinch();
			pinchDist = p.dist;
			pinchMidX = p.midX;
			pinchMidY = p.midY;
		}
	}
	function onpointermove(e: PointerEvent) {
		if (!pointers.has(e.pointerId)) return;
		pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
		if (pointers.size >= 2) {
			const p = pinch();
			if (pinchDist > 0) zoomAt(clampScale((scale * p.dist) / pinchDist), p.midX, p.midY);
			tx += p.midX - pinchMidX;
			ty += p.midY - pinchMidY;
			pinchDist = p.dist;
			pinchMidX = p.midX;
			pinchMidY = p.midY;
		} else if (dragging) {
			if (!captured) {
				if (Math.hypot(e.clientX - startX, e.clientY - startY) < DRAG_THRESHOLD) return;
				captured = true;
				(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
				lastX = e.clientX;
				lastY = e.clientY;
				return;
			}
			tx += e.clientX - lastX;
			ty += e.clientY - lastY;
			lastX = e.clientX;
			lastY = e.clientY;
		}
	}
	function endPointer(e: PointerEvent) {
		pointers.delete(e.pointerId);
		if (pointers.size === 1) {
			const [p] = [...pointers.values()];
			dragging = true;
			captured = true;
			lastX = p.x;
			lastY = p.y;
		} else if (pointers.size === 0) {
			dragging = false;
			captured = false;
		}
		if (pointers.size < 2) pinchDist = 0;
	}
	function onwheel(e: WheelEvent) {
		e.preventDefault();
		zoomAt(clampScale(scale - e.deltaY * 0.0016), e.clientX, e.clientY);
	}
	export function zoom(by: number) {
		if (!canvasEl) return;
		const rect = canvasEl.getBoundingClientRect();
		zoomAt(clampScale(scale + by), rect.left + rect.width / 2, rect.top + rect.height / 2);
	}

	function elbow(l: { fromX: number; fromY: number; toX: number; toY: number }) {
		const midY = (l.fromY + l.toY) / 2;
		return `M ${l.fromX} ${l.fromY} V ${midY} H ${l.toX} V ${l.toY}`;
	}
</script>

<div class="relative h-full w-full overflow-hidden" bind:clientWidth={vw} bind:clientHeight={vh}>
	{#if loading}
		<div class="flex h-full items-center justify-center">
			<p class="font-display tracking-[0.2em] text-ash/50 uppercase">Unrolling the lineage...</p>
		</div>
	{:else if !tree}
		<div class="flex h-full items-center justify-center">
			<p class="text-ash/60">This house could not be found.</p>
		</div>
	{:else if !layout || layout.nodes.length === 0}
		<div class="flex h-full flex-col items-center justify-center gap-3 text-center">
			<h1 class="font-display text-2xl text-ash uppercase">
				{tree.house ? `House ${tree.house.name}` : selectionLabel}
			</h1>
			<p class="max-w-sm text-ash/60">
				No lineage has been recorded yet. The maesters are still at work.
			</p>
		</div>
	{:else}
		<div
			bind:this={canvasEl}
			class="h-full w-full cursor-grab touch-none select-none active:cursor-grabbing"
			role="application"
			aria-label="Family tree canvas"
			onpointerdown={onpointerdown}
			onpointermove={onpointermove}
			onpointerup={endPointer}
			onpointercancel={endPointer}
			onpointerleave={endPointer}
			onwheel={onwheel}
		>
			<div
				class="absolute top-0 left-0 origin-top-left"
				style="width:{layout.width}px; height:{layout.height}px; transform: translate({tx}px, {ty}px) scale({scale});"
			>
				<svg
					class="absolute top-0 left-0 overflow-visible"
					width={layout.width}
					height={layout.height}
				>
					{#each layout.parentLinks as l, i (i)}
						<path d={elbow(l)} fill="none" stroke="rgba(159,178,191,0.32)" stroke-width="1.5" />
					{/each}
					{#each layout.marriageLinks as m, i (i)}
						<line
							x1={m.x1}
							y1={m.y1}
							x2={m.x2}
							y2={m.y2}
							stroke="rgba(200,162,74,0.5)"
							stroke-width="2"
							stroke-dasharray={m.isSecret ? '4 4' : ''}
						/>
					{/each}
				</svg>

				{#each layout.nodes as node (node.id)}
					<button
						type="button"
						onclick={() => onSelect(node.slug)}
						class="group absolute flex flex-col items-center bg-transparent text-center transition-transform duration-200 hover:scale-[1.05] {selectedMember ===
						node.slug
							? 'scale-[1.05]'
							: ''} {node.inHouse ? '' : 'opacity-75'}"
						style="left:{node.x}px; top:{node.y}px; width:{NODE_W}px; height:{NODE_H}px;"
					>
						<div class="relative" style="width:{FRAME_W}px; height:{FRAME_H}px;">
							<div class="absolute inset-[14%] overflow-hidden">
								{#if node.portraitPath}
									<img src={node.portraitPath} alt="" class="h-full w-full object-cover" />
								{:else}
									<div
										class="flex h-full w-full items-center justify-center bg-ink/60 font-display text-3xl text-ash/25"
									>
										{node.name.charAt(0)}
									</div>
								{/if}
							</div>
							{#if node.house?.framePath ?? tree.house?.framePath}
								<img
									src={node.house?.framePath ?? tree.house?.framePath}
									alt=""
									class="pointer-events-none relative block h-full w-full object-contain transition-[filter] duration-200 {selectedMember ===
									node.slug
										? 'drop-shadow-[0_0_10px_rgba(159,178,191,0.75)]'
										: 'group-hover:drop-shadow-[0_0_10px_rgba(159,178,191,0.6)]'}"
								/>
							{/if}
						</div>
						<div class="mt-1 flex flex-col items-center px-1 leading-tight">
							<div class="flex items-center gap-1">
								<span
									class="h-1.5 w-1.5 shrink-0 rounded-full {node.status === 'alive'
										? 'bg-emerald-400/80'
										: node.status === 'dead'
											? 'bg-red-500/70'
											: 'bg-ash/40'}"
								></span>
								<span class="font-display text-xs font-semibold text-ash">{displayName(node)}</span>
							</div>
							{#if node.epithet}
								<div class="truncate text-[10px] text-gold/60 italic">{node.epithet}</div>
							{/if}
							<div class="text-[10px] text-ash/45">{lifespan(node.bornYear, node.diedYear)}</div>
						</div>
					</button>
				{/each}
			</div>
		</div>

		<div class="absolute right-3 bottom-3 z-20 flex flex-col gap-1.5">
			<button
				type="button"
				onclick={() => zoom(0.2)}
				class="h-11 w-11 rounded-sm border border-white/10 bg-ink-soft/80 font-display text-xl text-ash/80 backdrop-blur-sm transition-colors hover:text-gold sm:h-9 sm:w-9 sm:text-lg"
				aria-label="Zoom in">+</button
			>
			<button
				type="button"
				onclick={() => zoom(-0.2)}
				class="h-11 w-11 rounded-sm border border-white/10 bg-ink-soft/80 font-display text-xl text-ash/80 backdrop-blur-sm transition-colors hover:text-gold sm:h-9 sm:w-9 sm:text-lg"
				aria-label="Zoom out">−</button
			>
		</div>

		<div
			class="pointer-events-none absolute bottom-3 left-3 z-20 hidden rounded-sm border border-white/10 bg-ink-soft/80 px-3 py-2 text-[11px] text-ash/60 backdrop-blur-sm sm:block"
		>
			<div class="font-display tracking-[0.2em] text-ash/80 uppercase">
				{tree.house ? tree.house.name : selectionLabel}
			</div>
			<div class="mt-1 flex items-center gap-2">
				<span class="inline-block h-px w-5 bg-[rgba(159,178,191,0.6)]"></span> Parent → child
			</div>
			<div class="mt-0.5 flex items-center gap-2">
				<span class="inline-block h-px w-5 bg-[rgba(200,162,74,0.7)]"></span> Marriage
			</div>
		</div>
	{/if}
</div>
