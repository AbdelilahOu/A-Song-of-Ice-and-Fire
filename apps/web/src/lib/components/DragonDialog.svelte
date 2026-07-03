<script lang="ts">
	import { client } from '$lib/orpc';
	import { displayName, formatYear, lifespan } from '$lib/format';
	import { buildDragonTimeline } from '$lib/life-events';
	import MiniTimeline from './MiniTimeline.svelte';

	type Props = {
		slug: string;
		onSelectMember: (slug: string) => void;
		onClose: () => void;
	};
	let { slug, onSelectMember, onClose }: Props = $props();

	let dragon = $state<Awaited<ReturnType<typeof client.dragons.getBySlug>> | null>(null);
	let loading = $state(true);
	let notFound = $state(false);

	$effect(() => {
		const s = slug;
		loading = true;
		notFound = false;
		dragon = null;
		client.dragons
			.getBySlug({ slug: s })
			.then((d) => {
				if (d) dragon = d;
				else notFound = true;
				loading = false;
			})
			.catch(() => {
				notFound = true;
				loading = false;
			});
	});

	let riders = $derived(dragon ? dragon.riders.filter((r) => r.member) : []);
	let timeline = $derived(dragon ? buildDragonTimeline(dragon) : []);

	const statusLabel: Record<string, string> = {
		alive: 'Living',
		dead: 'Slain',
		wild: 'Riderless',
		unknown: 'Fate unknown'
	};
	const sizeLabel: Record<string, string> = {
		hatchling: 'Hatchling',
		small: 'Small',
		medium: 'Medium',
		large: 'Large',
		great: 'Great',
		unknown: ''
	};
</script>

<aside
	class="fixed inset-y-0 right-0 z-50 flex w-full max-w-md flex-col border-l border-white/10 bg-ink-soft/95 shadow-2xl backdrop-blur-md"
>
	<div class="flex items-center justify-between border-b border-white/10 px-5 py-4">
		<span class="font-display text-xs tracking-[0.3em] text-red-400/70 uppercase">Dragon</span>
		<button
			type="button"
			onclick={onClose}
			class="font-display text-xs tracking-[0.2em] text-ash/60 uppercase transition-colors hover:text-gold"
		>
			Close
		</button>
	</div>

	<div class="flex-1 overflow-y-auto px-5 py-6">
		{#if loading}
			<p class="text-ash/50">Rousing the beast...</p>
		{:else if notFound || !dragon}
			<p class="text-ash/60">No record found for this dragon.</p>
		{:else}
			<header class="flex gap-4">
				<div
					class="flex h-28 w-20 shrink-0 items-center justify-center rounded-sm border border-white/10"
					style="background:
						radial-gradient(120% 120% at 50% 0%, {dragon.color
						? 'rgba(193,88,79,0.20)'
						: 'rgba(159,178,191,0.12)'}, transparent 70%), #0a0c0e;"
				>
					<span class="font-display text-4xl text-ash/40">{dragon.name.charAt(0)}</span>
				</div>
				<div class="min-w-0">
					<h2 class="font-display text-xl leading-tight font-semibold text-gold-bright">
						{dragon.name}
					</h2>
					{#if dragon.epithet}
						<p class="text-sm text-ash/70 italic">{dragon.epithet}</p>
					{/if}
					<p class="mt-2 text-xs tracking-wide text-ash/60 uppercase">
						{statusLabel[dragon.status] ?? dragon.status}
						{#if sizeLabel[dragon.size]}· {sizeLabel[dragon.size]}{/if}
					</p>
					{#if dragon.color}
						<p class="text-xs text-ash/50 capitalize">{dragon.color.replace(/-/g, ' ')} scales</p>
					{/if}
					<p class="text-xs text-ash/50">{lifespan(dragon.bornYear, dragon.diedYear)}</p>
				</div>
			</header>

			{#if dragon.notableFor}
				<p class="mt-4 text-sm leading-relaxed text-ash/75">{dragon.notableFor}</p>
			{/if}

			{#if dragon.notableRider}
				{@render section('Notable Rider')}
				<button
					type="button"
					onclick={() => onSelectMember(dragon!.notableRider!.slug)}
					class="mb-4 flex w-full items-center gap-3 rounded-sm border border-white/10 bg-ink/60 px-3 py-2 text-left transition-colors hover:border-gold/40"
				>
					<div class="relative h-10 w-8 shrink-0">
						<div class="absolute inset-[12%] overflow-hidden">
							{#if dragon.notableRider.portraitPath}
								<img src={dragon.notableRider.portraitPath} alt="" class="h-full w-full object-cover" />
							{:else}
								<div class="flex h-full w-full items-center justify-center bg-ink/60 text-ash/30">
									{dragon.notableRider.name.charAt(0)}
								</div>
							{/if}
						</div>
						{#if dragon.notableRider.house?.framePath}
							<img
								src={dragon.notableRider.house.framePath}
								alt=""
								class="pointer-events-none relative block h-full w-full object-contain"
							/>
						{/if}
					</div>
					<span class="font-display text-sm text-ash">{displayName(dragon.notableRider)}</span>
				</button>
			{/if}

			{#if riders.length > 1}
				{@render section('All Riders')}
				<div class="mb-4 flex flex-wrap gap-2">
					{#each riders as r (r.id)}
						<button
							type="button"
							onclick={() => onSelectMember(r.member!.slug)}
							class="rounded-sm border border-white/10 bg-ink/60 px-3 py-1.5 text-sm text-ash/80 transition-colors hover:border-gold/40 hover:text-gold-bright"
						>
							{displayName(r.member!)}
							{#if r.startYear}<span class="text-ash/40">· {formatYear(r.startYear)}</span>{/if}
						</button>
					{/each}
				</div>
			{/if}

			{#if dragon.description}
				{@render section('Lore')}
				<p class="mb-4 text-sm leading-relaxed text-ash/75">{dragon.description}</p>
			{/if}

			{#if dragon.achievements.length}
				{@render section('Feats')}
				<ul class="mb-4 space-y-2">
					{#each dragon.achievements as a (a.id)}
						<li class="rounded-sm border border-white/10 bg-ink/50 px-3 py-2">
							<div class="flex items-baseline justify-between gap-2">
								<span class="text-sm text-ash/85">{a.title}</span>
								{#if a.year != null}
									<span class="shrink-0 font-display text-[11px] text-ash/45">{formatYear(a.year)}</span>
								{/if}
							</div>
							{#if a.description}
								<p class="mt-0.5 text-xs leading-relaxed text-ash/55">{a.description}</p>
							{/if}
						</li>
					{/each}
				</ul>
			{/if}

			{#if timeline.length}
				{@render section('Chronicle')}
				<div class="mb-4">
					<MiniTimeline events={timeline} />
				</div>
			{/if}

			{#if dragon.fate}
				{@render section('Fate')}
				<p class="mb-4 text-sm leading-relaxed text-ash/75 italic">
					{dragon.fate}
					{#if dragon.killedInBattle?.war}
						<span class="text-ash/50"> — {dragon.killedInBattle.war.name}</span>
					{/if}
				</p>
			{/if}
		{/if}
	</div>
</aside>

{#snippet section(label: string)}
	<h3 class="mt-5 mb-2 font-display text-xs tracking-[0.25em] text-gold/60 uppercase">
		{label}
	</h3>
{/snippet}
