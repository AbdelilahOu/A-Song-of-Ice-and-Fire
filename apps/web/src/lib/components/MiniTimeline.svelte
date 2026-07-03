<script lang="ts">
	import { formatYear } from '$lib/format';
	import type { LifeEvent, LifeEventKind } from '$lib/life-events';

	let { events }: { events: LifeEvent[] } = $props();

	const kindColor: Record<LifeEventKind, string> = {
		birth: '#7fb4c9',
		title: '#c8a24a',
		marriage: '#c9a0c9',
		dragon: '#c1584f',
		event: '#9fb2bf',
		achievement: '#d9b24a',
		death: '#8a99a3'
	};
</script>

{#if events.length}
	<ol class="relative ml-1 border-l border-white/10">
		{#each events as e, i (i)}
			<li class="relative pb-4 pl-5 last:pb-0">
				<span
					class="absolute top-1 -left-[5px] h-2.5 w-2.5 rounded-full border border-ink"
					style="background:{kindColor[e.kind]}"
				></span>
				<div class="flex items-baseline gap-2">
					<span class="shrink-0 font-display text-[11px] tracking-wide text-ash/45">
						{formatYear(e.year)}
					</span>
					<span class="text-sm leading-snug text-ash/85">{e.label}</span>
				</div>
				{#if e.detail}
					<p class="mt-0.5 text-xs leading-relaxed text-ash/55">{e.detail}</p>
				{/if}
			</li>
		{/each}
	</ol>
{/if}
