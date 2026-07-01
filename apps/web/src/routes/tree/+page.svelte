<script lang="ts">
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { client } from '$lib/orpc';
	import FamilyTree from '$lib/components/FamilyTree.svelte';
	import MemberDialog from '$lib/components/MemberDialog.svelte';

	type HouseList = Awaited<ReturnType<typeof client.houses.list>>;

	let houseSlug = $derived($page.url.searchParams.get('house'));
	let selectedMember = $derived($page.url.searchParams.get('member'));

	let houses = $state<HouseList>([]);
	$effect(() => {
		client.houses
			.list()
			.then((h) => (houses = h))
			.catch(() => {});
	});

	function selectMember(slug: string) {
		const u = new URL($page.url);
		u.searchParams.set('member', slug);
		goto(u, { keepFocus: true, noScroll: true });
	}
	function closeMember() {
		const u = new URL($page.url);
		u.searchParams.delete('member');
		goto(u, { keepFocus: true, noScroll: true });
	}
</script>

<svelte:head>
	<title>{houseSlug ? 'The Family Tree' : 'The Great Houses'} — Westeros Lineages</title>
</svelte:head>

<div class="relative h-full w-full overflow-hidden">
	<!-- Switcher -->
	<div class="pointer-events-none absolute inset-x-0 top-0 z-20 p-3">
		<div
			class="pointer-events-auto mx-auto flex w-fit max-w-full gap-1 overflow-x-auto rounded-sm border border-white/10 bg-ink-soft/80 p-1 backdrop-blur-sm"
		>
			<a
				href="/tree"
				class="rounded-sm px-3 py-1.5 font-display text-xs tracking-[0.15em] uppercase transition-colors {!houseSlug
					? 'bg-gold/15 text-gold-bright'
					: 'text-ash/60 hover:text-gold'}"
			>
				All Houses
			</a>
			<span class="my-1 w-px bg-white/10"></span>
			{#each houses as h (h.slug)}
				<a
					href={`/tree?house=${h.slug}`}
					class="rounded-sm px-3 py-1.5 font-display text-xs tracking-[0.15em] uppercase transition-colors {h.slug ===
					houseSlug
						? 'bg-gold/15 text-gold-bright'
						: 'text-ash/60 hover:text-gold'}"
				>
					{h.name}
				</a>
			{/each}
		</div>
	</div>

	{#key houseSlug}
		<FamilyTree slug={houseSlug} {selectedMember} onSelect={selectMember} />
	{/key}

	{#if selectedMember}
		<MemberDialog slug={selectedMember} onSelect={selectMember} onClose={closeMember} />
	{/if}
</div>
