<script lang="ts">
	import { page } from '$app/stores';
	import { client } from '$lib/orpc';
	import { displayName, lifespan } from '$lib/format';

	type House = Awaited<ReturnType<typeof client.houses.getBySlug>>;

	let slug = $derived($page.params.slug);
	let house = $state<House>(null);
	let loading = $state(true);

	$effect(() => {
		const s = slug;
		loading = true;
		client.houses
			.getBySlug({ slug: s })
			.then((h) => {
				house = h ?? null;
				loading = false;
			})
			.catch(() => {
				house = null;
				loading = false;
			});
	});

	let relations = $derived.by(() => {
		if (!house) return [];
		return [
			...house.relationsA.map((r) => ({ ...r, other: r.houseB })),
			...house.relationsB.map((r) => ({ ...r, other: r.houseA }))
		];
	});

	const relationLabel: Record<string, string> = {
		alliance: 'Allied with',
		rivalry: 'Rival of',
		feud: 'Feud with',
		war: 'At war with',
		vassalage: 'Bound to',
		cadet_branch: 'Branch of',
		marriage_pact: 'Wed to'
	};
</script>

<svelte:head>
	<title>{house ? `House ${house.name}` : 'House'} — Westeros Lineages</title>
</svelte:head>

{#if loading}
	<div class="flex min-h-full items-center justify-center">
		<p class="font-display tracking-[0.2em] text-ash/50 uppercase">Reading the annals...</p>
	</div>
{:else if !house}
	<div class="flex min-h-full flex-col items-center justify-center gap-3">
		<p class="text-ash/60">No such house is known.</p>
		<a href="/" class="font-display text-sm tracking-[0.2em] text-gold uppercase">Return Home</a>
	</div>
{:else}
	<div class="mx-auto max-w-5xl px-4 py-12 md:py-16">
		<header class="flex flex-col items-center gap-6 text-center md:flex-row md:text-left">
			{#if house.bannerPath}
				<img
					src={house.bannerPath}
					alt={`House ${house.name} banner`}
					class="h-56 w-40 shrink-0 rounded-sm border border-white/10 object-cover shadow-2xl"
				/>
			{/if}
			<div class="min-w-0">
				<p class="font-display text-xs tracking-[0.4em] text-gold/70 uppercase">
					{house.region ?? 'Westeros'}
				</p>
				<h1
					class="mt-3 font-display text-4xl font-semibold text-transparent uppercase md:text-5xl"
					style="background: linear-gradient(180deg, #eef4f7 0%, #9fb2bf 60%, #55636d 100%); -webkit-background-clip: text; background-clip: text;"
				>
					House {house.name}
				</h1>
				{#if house.words}
					<p class="mt-3 font-display text-lg text-gold/80 italic">"{house.words}"</p>
				{/if}
				<div class="mt-4 flex flex-wrap justify-center gap-x-6 gap-y-1 text-sm text-ash/60 md:justify-start">
					{#if house.seat}<span>Seat: {house.seat}</span>{/if}
					{#if house.sigilDescription}<span>Sigil: {house.sigilDescription}</span>{/if}
				</div>
				<a
					href={`/tree?house=${house.slug}`}
					class="mt-6 inline-flex border border-gold/40 bg-gradient-to-b from-blood/60 to-ink px-6 py-2.5 font-display text-sm tracking-[0.2em] text-gold-bright uppercase transition-all hover:border-gold"
				>
					View the Family Tree
				</a>
			</div>
		</header>

		{#if house.summary}
			<p class="mx-auto mt-10 max-w-3xl text-center text-lg leading-relaxed text-ash/75">
				{house.summary}
			</p>
		{/if}

		{#if relations.length}
			<section class="mt-12">
				<h2 class="mb-4 font-display text-xs tracking-[0.3em] text-gold/60 uppercase">
					Ties & Rivalries
				</h2>
				<div class="flex flex-wrap gap-2">
					{#each relations as r (r.id)}
						<a
							href={`/house/${r.other.slug}`}
							class="rounded-sm border border-white/10 bg-ink-soft/60 px-3 py-1.5 text-sm text-ash/80 transition-colors hover:border-gold/40 hover:text-gold-bright"
						>
							<span class="text-ash/50">{relationLabel[r.type] ?? r.type}</span>
							House {r.other.name}
						</a>
					{/each}
				</div>
			</section>
		{/if}

		<section class="mt-12">
			<h2 class="mb-4 font-display text-xs tracking-[0.3em] text-gold/60 uppercase">
				Members ({house.members.length})
			</h2>
			{#if house.members.length === 0}
				<p class="text-ash/60">No members have been recorded for this house yet.</p>
			{:else}
				<div class="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4">
					{#each house.members as m (m.id)}
						<a
							href={`/tree?house=${house.slug}&member=${m.slug}`}
							class="group rounded-sm border border-white/10 bg-ink-soft/60 p-3 transition-colors hover:border-gold/40"
						>
							<div class="flex items-center justify-between">
								<span class="font-display text-sm font-semibold text-ash group-hover:text-gold-bright">
									{displayName(m)}
								</span>
								<span
									class="h-2 w-2 shrink-0 rounded-full {m.status === 'alive'
										? 'bg-emerald-400/80'
										: m.status === 'dead'
											? 'bg-red-500/70'
											: 'bg-ash/40'}"
								></span>
							</div>
							{#if m.epithet}
								<div class="truncate text-xs text-gold/60 italic">{m.epithet}</div>
							{/if}
							<div class="mt-1 text-xs text-ash/45">{lifespan(m.bornYear, m.diedYear)}</div>
							{#if m.notableFor}
								<div class="mt-1 line-clamp-2 text-[11px] text-ash/55">{m.notableFor}</div>
							{/if}
						</a>
					{/each}
				</div>
			{/if}
		</section>
	</div>
{/if}
