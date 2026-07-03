<script lang="ts">
	import { client } from '$lib/orpc';

	type HouseList = Awaited<ReturnType<typeof client.houses.list>>;

	// Stylized schematic of Westeros. Each Great House's territory is an SVG
	// <path> keyed by house slug; live house data (name, words, region) is
	// merged in from houses.list so the map stays in sync with the DB.
	type Territory = {
		slug: string;
		defaultRegion: string;
		color: string;
		path: string;
		labelX: number;
		labelY: number;
	};

	const territories: Territory[] = [
		{
			slug: 'stark',
			defaultRegion: 'The North',
			color: '#8ea3b0',
			path: 'M150,45 L330,55 L358,150 L338,235 L235,248 L150,248 L128,150 Z',
			labelX: 243,
			labelY: 150
		},
		{
			slug: 'greyjoy',
			defaultRegion: 'Iron Islands',
			color: '#6b7f8c',
			path: 'M66,300 L112,292 L124,326 L96,360 L60,336 Z',
			labelX: 92,
			labelY: 326
		},
		{
			slug: 'arryn',
			defaultRegion: 'The Vale',
			color: '#6ea2c9',
			path: 'M300,255 L360,250 L392,300 L372,352 L305,346 L292,300 Z',
			labelX: 340,
			labelY: 302
		},
		{
			slug: 'tully',
			defaultRegion: 'The Riverlands',
			color: '#4f8a8b',
			path: 'M150,258 L292,262 L300,320 L262,360 L150,352 L138,300 Z',
			labelX: 218,
			labelY: 312
		},
		{
			slug: 'lannister',
			defaultRegion: 'The Westerlands',
			color: '#9e2b3a',
			path: 'M118,360 L232,362 L244,415 L232,445 L120,440 L104,400 Z',
			labelX: 172,
			labelY: 404
		},
		{
			slug: 'targaryen',
			defaultRegion: 'The Crownlands',
			color: '#a33240',
			path: 'M300,356 L372,362 L388,412 L342,436 L300,414 Z',
			labelX: 344,
			labelY: 396
		},
		{
			slug: 'tyrell',
			defaultRegion: 'The Reach',
			color: '#5a8f4e',
			path: 'M104,442 L244,448 L298,440 L298,548 L206,582 L118,548 L96,492 Z',
			labelX: 196,
			labelY: 502
		},
		{
			slug: 'baratheon',
			defaultRegion: 'The Stormlands',
			color: '#caa03a',
			path: 'M300,440 L342,438 L388,416 L398,520 L340,556 L300,550 Z',
			labelX: 348,
			labelY: 486
		},
		{
			slug: 'martell',
			defaultRegion: 'Dorne',
			color: '#c2703a',
			path: 'M150,556 L300,552 L360,548 L346,628 L250,664 L172,626 Z',
			labelX: 252,
			labelY: 606
		}
	];

	let houses = $state<HouseList>([]);
	let hovered = $state<string | null>(null);
	let selected = $state<string | null>(null);

	$effect(() => {
		client.houses
			.list()
			.then((h) => (houses = h))
			.catch(() => {});
	});

	const houseBySlug = $derived(new Map(houses.map((h) => [h.slug, h])));
	const active = $derived(selected ?? hovered);
	const activeHouse = $derived(active ? houseBySlug.get(active) : undefined);
	const activeTerritory = $derived(territories.find((t) => t.slug === active));

	function select(slug: string) {
		selected = selected === slug ? null : slug;
	}
</script>

<svelte:head>
	<title>The Map of Westeros — Westeros Lineages</title>
</svelte:head>

<div class="mx-auto max-w-6xl px-4 py-10 md:py-14">
	<header class="text-center">
		<p class="font-display text-xs tracking-[0.4em] text-gold/70 uppercase">The Known World</p>
		<h1
			class="mt-3 font-display text-4xl font-semibold text-transparent uppercase md:text-5xl"
			style="background: linear-gradient(180deg, #eef4f7 0%, #9fb2bf 60%, #55636d 100%); -webkit-background-clip: text; background-clip: text;"
		>
			The Map of Westeros
		</h1>
		<p class="mx-auto mt-4 max-w-2xl text-ash/60">
			The territories of the nine Great Houses. Hover a realm to name it; select one to open its
			house and family tree.
		</p>
	</header>

	<div class="mt-10 grid gap-8 md:grid-cols-[minmax(0,1fr)_20rem]">
		<!-- Map -->
		<div class="relative rounded-sm border border-white/10 bg-ink-soft/40 p-2">
			<svg
				viewBox="0 0 440 700"
				class="h-auto w-full"
				role="group"
				aria-label="Interactive map of the territories of Westeros"
			>
				{#each territories as t (t.slug)}
					{@const house = houseBySlug.get(t.slug)}
					{@const isActive = active === t.slug}
					{@const dim = active !== null && !isActive}
					<g
						role="button"
						tabindex="0"
						aria-label={`${house?.name ? `House ${house.name}` : t.slug} — ${house?.region ?? t.defaultRegion}`}
						onmouseenter={() => (hovered = t.slug)}
						onmouseleave={() => (hovered = null)}
						onfocus={() => (hovered = t.slug)}
						onblur={() => (hovered = null)}
						onclick={() => select(t.slug)}
						onkeydown={(e) => {
							if (e.key === 'Enter' || e.key === ' ') {
								e.preventDefault();
								select(t.slug);
							}
						}}
						class="cursor-pointer outline-none"
					>
						<path
							d={t.path}
							fill={t.color}
							fill-opacity={isActive ? 0.85 : dim ? 0.12 : 0.4}
							stroke={isActive ? '#eef4f7' : 'rgba(255,255,255,0.18)'}
							stroke-width={isActive ? 1.6 : 0.8}
							class="transition-all duration-200"
						/>
						<text
							x={t.labelX}
							y={t.labelY}
							text-anchor="middle"
							class="pointer-events-none font-display uppercase select-none"
							fill={isActive ? '#eef4f7' : '#c7d2da'}
							fill-opacity={dim ? 0.35 : 0.9}
							style="font-size: 11px; letter-spacing: 0.12em;"
						>
							{house?.region ?? t.defaultRegion}
						</text>
					</g>
				{/each}
			</svg>
		</div>

		<!-- Detail panel -->
		<aside class="rounded-sm border border-white/10 bg-ink-soft/60 p-5">
			{#if activeHouse && activeTerritory}
				<p class="font-display text-xs tracking-[0.35em] text-gold/70 uppercase">
					{activeHouse.region ?? activeTerritory.defaultRegion}
				</p>
				<h2 class="mt-2 font-display text-2xl font-semibold text-gold-bright uppercase">
					House {activeHouse.name}
				</h2>
				{#if activeHouse.words}
					<p class="mt-2 font-display text-gold/80 italic">"{activeHouse.words}"</p>
				{/if}
				{#if activeHouse.seat}
					<p class="mt-3 text-sm text-ash/60">Seat: {activeHouse.seat}</p>
				{/if}

				<div class="mt-5 flex flex-col gap-2">
					<a
						href={`/house/${activeHouse.slug}`}
						class="inline-flex justify-center border border-gold/40 bg-gradient-to-b from-blood/60 to-ink px-4 py-2 font-display text-xs tracking-[0.2em] text-gold-bright uppercase transition-all hover:border-gold"
					>
						View the House
					</a>
					<a
						href={`/tree?house=${activeHouse.slug}`}
						class="inline-flex justify-center border border-white/10 bg-ink/40 px-4 py-2 font-display text-xs tracking-[0.2em] text-ash uppercase transition-all hover:border-gold/40 hover:text-gold-bright"
					>
						Focus the Family Tree
					</a>
				</div>
			{:else}
				<p class="font-display text-xs tracking-[0.35em] text-ash/50 uppercase">The Great Houses</p>
				<ul class="mt-4 flex flex-col gap-1">
					{#each territories as t (t.slug)}
						{@const house = houseBySlug.get(t.slug)}
						<li>
							<button
								type="button"
								onmouseenter={() => (hovered = t.slug)}
								onmouseleave={() => (hovered = null)}
								onclick={() => select(t.slug)}
								class="flex w-full items-center gap-2.5 rounded-sm px-2 py-1.5 text-left text-sm text-ash/75 transition-colors hover:bg-white/5 hover:text-gold-bright"
							>
								<span
									class="h-2.5 w-2.5 shrink-0 rounded-full"
									style={`background:${t.color}`}
								></span>
								<span class="font-display tracking-wide">{house?.name ?? t.slug}</span>
								<span class="ml-auto text-xs text-ash/40">{house?.region ?? t.defaultRegion}</span>
							</button>
						</li>
					{/each}
				</ul>
				<p class="mt-4 text-xs text-ash/40">Select a realm on the map for details.</p>
			{/if}
		</aside>
	</div>
</div>
