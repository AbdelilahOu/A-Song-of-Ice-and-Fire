<script lang="ts">
	import { client } from '$lib/orpc';

	type Overview = Awaited<ReturnType<typeof client.tree.overview>>;
	type House = Overview['houses'][number];

	type Props = { onOpenHouse: (slug: string) => void };
	let { onOpenHouse }: Props = $props();

	let data = $state<Overview | null>(null);
	let loading = $state(true);

	$effect(() => {
		loading = true;
		client.tree
			.overview()
			.then((d) => {
				data = d;
				loading = false;
			})
			.catch(() => {
				data = null;
				loading = false;
			});
	});

	// Relation styling.
	const REL: Record<string, { color: string; label: string }> = {
		alliance: { color: '#4ea36f', label: 'Alliance' },
		marriage_pact: { color: '#c8a24a', label: 'Marriage pact' },
		war: { color: '#c0392b', label: 'War' },
		rivalry: { color: '#d08245', label: 'Rivalry' },
		feud: { color: '#a85a3c', label: 'Feud' },
		vassalage: { color: '#5a86b0', label: 'Vassalage' },
		cadet_branch: { color: '#8a6fb0', label: 'Cadet branch' }
	};
	const relStyle = (t: string) => REL[t] ?? { color: '#8896a0', label: t };

	// Circular layout.
	const R = 300;
	const CENTER = 380;
	const SIZE = CENTER * 2;
	const NODE = 96;

	let positions = $derived.by(() => {
		const map = new Map<number, { x: number; y: number; house: House; angle: number }>();
		if (!data) return map;
		const n = data.houses.length;
		data.houses.forEach((h, i) => {
			const angle = -Math.PI / 2 + (i * 2 * Math.PI) / n;
			map.set(h.id, {
				house: h,
				angle,
				x: CENTER + R * Math.cos(angle),
				y: CENTER + R * Math.sin(angle)
			});
		});
		return map;
	});

	let edges = $derived.by(() => {
		if (!data) return [];
		return data.relations
			.map((r) => {
				const a = positions.get(r.houseAId);
				const b = positions.get(r.houseBId);
				if (!a || !b) return null;
				// Bow the curve toward the centre for readability.
				const mx = (a.x + b.x) / 2;
				const my = (a.y + b.y) / 2;
				const cx = mx + (CENTER - mx) * 0.35;
				const cy = my + (CENTER - my) * 0.35;
				return {
					id: r.id,
					aId: r.houseAId,
					bId: r.houseBId,
					type: r.type,
					path: `M ${a.x} ${a.y} Q ${cx} ${cy} ${b.x} ${b.y}`
				};
			})
			.filter((e): e is NonNullable<typeof e> => e !== null);
	});

	let presentTypes = $derived(
		data ? [...new Set(data.relations.map((r) => r.type))] : []
	);

	let hovered = $state<number | null>(null);
	let connected = $derived.by(() => {
		const set = new Set<number>();
		if (hovered == null || !data) return set;
		for (const r of data.relations) {
			if (r.houseAId === hovered) set.add(r.houseBId);
			if (r.houseBId === hovered) set.add(r.houseAId);
		}
		return set;
	});

	const isDim = (id: number) => hovered != null && hovered !== id && !connected.has(id);
	const edgeActive = (e: { aId: number; bId: number }) =>
		hovered == null || e.aId === hovered || e.bId === hovered;

	// Pan / zoom
	let vw = $state(0);
	let scale = $state(0.85);
	let tx = $state(0);
	let ty = $state(0);
	let dragging = false;
	let lastX = 0;
	let lastY = 0;
	let centered = false;

	$effect(() => {
		if (vw && !centered) {
			scale = Math.min(1, Math.max(0.4, (Math.min(vw, 900) - 40) / SIZE));
			tx = (vw - SIZE * scale) / 2;
			ty = 20;
			centered = true;
		}
	});

	function onpointerdown(e: PointerEvent) {
		dragging = true;
		lastX = e.clientX;
		lastY = e.clientY;
		(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
	}
	function onpointermove(e: PointerEvent) {
		if (!dragging) return;
		tx += e.clientX - lastX;
		ty += e.clientY - lastY;
		lastX = e.clientX;
		lastY = e.clientY;
	}
	function onpointerup() {
		dragging = false;
	}
	function onwheel(e: WheelEvent) {
		e.preventDefault();
		scale = Math.min(1.8, Math.max(0.3, scale - e.deltaY * 0.0016));
	}
	function zoom(by: number) {
		scale = Math.min(1.8, Math.max(0.3, scale + by));
	}
</script>

<div class="relative h-full w-full overflow-hidden" bind:clientWidth={vw}>
	{#if loading}
		<div class="flex h-full items-center justify-center">
			<p class="font-display tracking-[0.2em] text-ash/50 uppercase">Charting the realm...</p>
		</div>
	{:else if !data || data.houses.length === 0}
		<div class="flex h-full items-center justify-center">
			<p class="text-ash/60">No houses have been recorded yet.</p>
		</div>
	{:else}
		<div
			class="h-full w-full cursor-grab touch-none select-none active:cursor-grabbing"
			role="application"
			aria-label="Houses of Westeros"
			onpointerdown={onpointerdown}
			onpointermove={onpointermove}
			onpointerup={onpointerup}
			onpointerleave={onpointerup}
			onwheel={onwheel}
		>
			<div
				class="absolute top-0 left-0 origin-top-left"
				style="width:{SIZE}px; height:{SIZE}px; transform: translate({tx}px, {ty}px) scale({scale});"
			>
				<svg class="absolute top-0 left-0" width={SIZE} height={SIZE}>
					{#each edges as e (e.id)}
						<path
							d={e.path}
							fill="none"
							stroke={relStyle(e.type).color}
							stroke-width={edgeActive(e) ? 2.5 : 1.5}
							stroke-opacity={edgeActive(e) ? 0.9 : 0.15}
						/>
					{/each}
				</svg>

				{#each [...positions.values()] as p (p.house.id)}
					<button
						type="button"
						onclick={() => onOpenHouse(p.house.slug)}
						onpointerenter={() => (hovered = p.house.id)}
						onpointerleave={() => (hovered = null)}
						class="group absolute flex flex-col items-center bg-transparent text-center transition-all duration-200 hover:scale-105 {isDim(
							p.house.id
						)
							? 'opacity-30'
							: 'opacity-100'}"
						style="left:{p.x - NODE / 2}px; top:{p.y - NODE / 2}px; width:{NODE}px;"
					>
						<div
							class="h-24 w-16 overflow-hidden rounded-sm border border-white/10 shadow-lg transition-shadow group-hover:border-gold/50 group-hover:shadow-[0_0_18px_-4px_rgba(159,178,191,0.6)]"
						>
							{#if p.house.bannerPath}
								<img src={p.house.bannerPath} alt="" class="h-full w-full object-cover" />
							{:else}
								<div class="flex h-full w-full items-center justify-center bg-ink-soft">
									<span class="font-display text-xl text-ash/50">{p.house.name.charAt(0)}</span>
								</div>
							{/if}
						</div>
						<div class="mt-1.5 font-display text-xs font-semibold tracking-wide text-ash uppercase">
							{p.house.name}
						</div>
						<div class="text-[10px] text-ash/45">{p.house.memberCount} recorded</div>
					</button>
				{/each}
			</div>
		</div>

		<!-- Title -->
		<div class="pointer-events-none absolute inset-x-0 top-16 z-10 text-center">
			<p class="font-display text-xs tracking-[0.4em] text-gold/60 uppercase">The Great Houses</p>
			<p class="mt-1 text-sm text-ash/50">Select a house to trace its lineage</p>
		</div>

		<!-- Zoom controls -->
		<div class="absolute right-3 bottom-3 z-20 flex flex-col gap-1">
			<button
				type="button"
				onclick={() => zoom(0.15)}
				class="h-9 w-9 rounded-sm border border-white/10 bg-ink-soft/80 font-display text-lg text-ash/80 backdrop-blur-sm transition-colors hover:text-gold"
				aria-label="Zoom in">+</button
			>
			<button
				type="button"
				onclick={() => zoom(-0.15)}
				class="h-9 w-9 rounded-sm border border-white/10 bg-ink-soft/80 font-display text-lg text-ash/80 backdrop-blur-sm transition-colors hover:text-gold"
				aria-label="Zoom out">−</button
			>
		</div>

		<!-- Relation legend -->
		{#if presentTypes.length}
			<div
				class="absolute bottom-3 left-3 z-20 rounded-sm border border-white/10 bg-ink-soft/80 px-3 py-2 backdrop-blur-sm"
			>
				<div class="mb-1 font-display text-[10px] tracking-[0.2em] text-ash/70 uppercase">
					Relations
				</div>
				<div class="grid grid-cols-2 gap-x-4 gap-y-1">
					{#each presentTypes as t (t)}
						<div class="flex items-center gap-2 text-[11px] text-ash/70">
							<span
								class="inline-block h-0.5 w-4 rounded-full"
								style="background:{relStyle(t).color}"
							></span>
							{relStyle(t).label}
						</div>
					{/each}
				</div>
			</div>
		{/if}
	{/if}
</div>
