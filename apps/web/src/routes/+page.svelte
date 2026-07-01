<script lang="ts">
	import { PUBLIC_ASSET_URL } from '$env/static/public';

	const houses = [
		{ slug: 'targaryen', name: 'Targaryen', words: 'Fire and Blood' },
		{ slug: 'stark', name: 'Stark', words: 'Winter Is Coming' },
		{ slug: 'lannister', name: 'Lannister', words: 'Hear Me Roar' },
		{ slug: 'baratheon', name: 'Baratheon', words: 'Ours Is the Fury' },
		{ slug: 'tully', name: 'Tully', words: 'Family, Duty, Honor' },
		{ slug: 'arryn', name: 'Arryn', words: 'As High as Honor' },
		{ slug: 'tyrell', name: 'Tyrell', words: 'Growing Strong' },
		{ slug: 'martell', name: 'Martell', words: 'Unbowed, Unbent, Unbroken' },
		{ slug: 'greyjoy', name: 'Greyjoy', words: 'We Do Not Sow' }
	];
</script>

<svelte:head>
	<title>Westeros Lineages — The Great Houses</title>
	<meta
		name="description"
		content="Explore the family trees of the Great Houses of Westeros — the bloodlines, marriages, and heirs of A Song of Ice and Fire."
	/>
</svelte:head>

<section class="relative flex min-h-full flex-col items-center overflow-hidden px-4 py-16 md:py-24">
	<!-- Ambient frost glow -->
	<div
		class="pointer-events-none absolute top-[-10%] left-1/2 h-[520px] w-[520px] -translate-x-1/2 rounded-full bg-ember/10 blur-[120px]"
	></div>

	<div class="relative z-10 mx-auto flex max-w-3xl flex-col items-center text-center">
		<span class="font-display text-xs tracking-[0.45em] text-gold/70 uppercase md:text-sm">
			A Song of Ice and Fire
		</span>

		<h1
			class="mt-6 font-display text-4xl leading-[1.05] font-semibold text-transparent uppercase sm:text-5xl md:text-6xl"
			style="background: linear-gradient(180deg, #eef4f7 0%, #9fb2bf 60%, #55636d 100%); -webkit-background-clip: text; background-clip: text;"
		>
			The Great Houses<br />of Westeros
		</h1>

		<p class="mt-6 max-w-xl text-lg leading-relaxed text-ash/80 md:text-xl">
			Trace the bloodlines that shaped the Seven Kingdoms — the marriages, the
			heirs, and the rivalries that bind the realm together. A living map of
			every family, every claim, every fall.
		</p>

		<div class="mt-10 flex flex-col items-center gap-4 sm:flex-row">
			<a
				href="/tree"
				class="group relative inline-flex items-center gap-2 border border-gold/40 bg-gradient-to-b from-blood/60 to-ink px-8 py-3 font-display text-sm tracking-[0.2em] text-gold-bright uppercase transition-all hover:border-gold hover:from-blood hover:shadow-[0_0_30px_-6px_rgba(140,170,195,0.5)]"
			>
				Enter the Realm
			</a>
			<a
				href="/login"
				class="font-display text-sm tracking-[0.2em] text-ash/60 uppercase transition-colors hover:text-gold"
			>
				Sign In
			</a>
		</div>
	</div>

	<!-- The nine banners -->
	<div class="relative z-10 mt-20 w-full max-w-6xl">
		<div
			class="mb-8 flex flex-nowrap items-center justify-center gap-3 text-xs tracking-[0.2em] text-ash/40 uppercase sm:gap-4 sm:tracking-[0.3em]"
		>
			<span class="h-px w-8 shrink-0 bg-gradient-to-r from-transparent to-gold/30 sm:w-12"></span>
			<span class="font-display whitespace-nowrap">The Nine Houses</span>
			<span class="h-px w-8 shrink-0 bg-gradient-to-l from-transparent to-gold/30 sm:w-12"></span>
		</div>

		<div class="grid grid-cols-3 gap-3 lg:grid-cols-9">
			{#each houses as house (house.slug)}
				<a
					href="/tree?house={house.slug}"
					class="group relative aspect-[2/3] overflow-hidden rounded-sm border border-white/5"
					title={house.name}
				>
					<img
						src="{PUBLIC_ASSET_URL}/houses/{house.slug}/banner.webp"
						alt="House {house.name} banner"
						loading="lazy"
						class="h-full w-full object-cover opacity-70 grayscale-[35%] transition-all duration-500 group-hover:scale-105 group-hover:opacity-100 group-hover:grayscale-0"
					/>
					<div
						class="absolute inset-0 bg-gradient-to-t from-ink via-ink/10 to-transparent"
					></div>
					<div
						class="absolute inset-x-0 bottom-0 p-2 text-center opacity-0 transition-opacity duration-300 group-hover:opacity-100"
					>
						<div class="font-display text-xs font-semibold tracking-wider text-gold-bright uppercase">
							{house.name}
						</div>
						<div class="mt-0.5 text-[10px] leading-tight text-ash/70 italic">
							{house.words}
						</div>
					</div>
				</a>
			{/each}
		</div>
	</div>
</section>
