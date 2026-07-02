<script lang="ts">
	import { client } from '$lib/orpc';
	import { displayName } from '$lib/format';
	import { layoutTimeline, PX_PER_YEAR, type TimelineLayout } from '$lib/timeline-layout';

	type Data = Awaited<ReturnType<typeof client.timeline.all>>;

	type Props = {
		selectedMember: string | null;
		onSelect: (slug: string) => void;
	};
	let { selectedMember, onSelect }: Props = $props();

	let data = $state<Data | null>(null);
	let loading = $state(true);

	$effect(() => {
		loading = true;
		client.timeline
			.all()
			.then((r) => {
				data = r;
				loading = false;
			})
			.catch(() => {
				data = null;
				loading = false;
			});
	});

	let layout = $derived<TimelineLayout | null>(
		data ? layoutTimeline(data.members, data.events, data.wars) : null
	);
</script>

<div class="relative h-full w-full overflow-hidden">
	{#if loading}
		<div class="flex h-full items-center justify-center">
			<p class="font-display tracking-[0.2em] text-ash/50 uppercase">Reading the annals...</p>
		</div>
	{:else if !layout || layout.bars.length === 0}
		<div class="flex h-full flex-col items-center justify-center gap-3 text-center">
			<h1 class="font-display text-2xl text-ash uppercase">The Chronicle</h1>
			<p class="max-w-sm text-ash/60">
				No dated lives have been recorded yet. The maesters are still at work.
			</p>
		</div>
	{:else}
		<div
			class="h-full w-full overflow-auto"
			role="application"
			aria-label="Chronological timeline"
		>
			<div class="relative" style="width:{layout.width}px; height:{layout.height}px;">
				<div
					class="absolute top-0 left-0 origin-top-left"
					style="width:{layout.width}px; height:{layout.height}px;"
				>
					<svg
						class="absolute top-0 left-0 overflow-visible"
						width={layout.width}
						height={layout.height}
					>
						<!-- Band background stripes -->
						{#each layout.bands as band (band.key)}
							<rect
								x={layout.laneStartX - 8}
								y={band.y - 4}
								width={layout.width - layout.laneStartX}
								height={band.height}
								fill={band.color}
								opacity="0.04"
							/>
						{/each}

						<!-- Year gridlines + axis ticks -->
						{#each layout.ticks as t (t.year)}
							<line
								x1={t.x}
								y1={layout.axisH - 6}
								x2={t.x}
								y2={layout.height - 12}
								stroke="rgba(159,178,191,0.10)"
								stroke-width="1"
							/>
							<text
								x={t.x}
								y={layout.axisH - 14}
								text-anchor="middle"
								class="fill-ash/55 font-display"
								style="font-size:11px; letter-spacing:0.08em;">{t.label}</text
							>
						{/each}

						<!-- Year zero (Aegon's Conquest) emphasis -->
						{#if layout.minYear < 0 && layout.maxYear > 0}
							<line
								x1={layout.laneStartX + -layout.minYear * PX_PER_YEAR}
								y1={layout.axisH - 6}
								x2={layout.laneStartX + -layout.minYear * PX_PER_YEAR}
								y2={layout.height - 12}
								stroke="rgba(200,162,74,0.35)"
								stroke-width="1.5"
								stroke-dasharray="3 3"
							/>
						{/if}

						<!-- War spans -->
						{#each layout.wars as w (w.war.id)}
							<rect
								x={w.x}
								y={layout.axisH - 4}
								width={w.w}
								height={layout.height - layout.axisH - 8}
								fill="rgba(193,88,79,0.06)"
							/>
							<text x={w.x + 3} y={layout.axisH + 6} class="fill-ash/40" style="font-size:9px;"
								>{w.war.name}</text
							>
						{/each}
					</svg>

					<!-- House band labels -->
					{#each layout.bands as band (band.key)}
						<div
							class="absolute flex items-center"
							style="left:0; top:{band.y}px; width:120px; height:{band.height}px;"
						>
							<span
								class="border-l-2 pl-2 font-display text-[11px] font-semibold tracking-[0.12em] uppercase"
								style="border-color:{band.color}; color:{band.color};">{band.name}</span
							>
						</div>
					{/each}

					<!-- Member lifespan bars -->
					{#each layout.bars as bar (bar.member.id)}
						<button
							type="button"
							onclick={() => onSelect(bar.member.slug)}
							title={displayName(bar.member)}
							class="group absolute flex items-center rounded-[3px] px-1.5 text-left transition-[filter,transform] hover:z-10 hover:brightness-125 {selectedMember ===
							bar.member.slug
								? 'z-10 ring-1 ring-gold-bright'
								: ''}"
							style="left:{bar.x}px; top:{bar.y}px; width:{bar.w}px; height:{bar.h}px;
								background:{bar.color}22; border:1px solid {bar.color}88;
								{bar.openEnded ? 'border-right-style:dashed;' : ''}"
						>
							<span
								class="truncate font-display text-[10px] leading-none font-medium"
								style="color:{bar.color};"
							>
								{bar.member.name}
								{#if bar.isAlive}<span class="text-emerald-400/80">•</span>{/if}
							</span>
						</button>
					{/each}
				</div>
			</div>
		</div>

		<div
			class="pointer-events-none absolute bottom-3 left-3 z-20 hidden rounded-sm border border-white/10 bg-ink-soft/80 px-3 py-2 text-[11px] text-ash/60 backdrop-blur-sm sm:block"
		>
			<div class="font-display tracking-[0.2em] text-ash/80 uppercase">The Chronicle</div>
			<div class="mt-1">Each bar is a life; length is its span.</div>
			<div class="mt-0.5 flex items-center gap-2">
				<span class="inline-block h-2 w-4 rounded-[2px] border border-dashed border-ash/50"></span>
				Death year unknown
			</div>
			<div class="mt-0.5 flex items-center gap-2">
				<span class="text-emerald-400/80">•</span> Still living
			</div>
		</div>
	{/if}
</div>
