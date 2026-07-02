<script lang="ts">
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { client } from '$lib/orpc';
	import FamilyTree from '$lib/components/FamilyTree.svelte';
	import Chronicle from '$lib/components/Chronicle.svelte';
	import MemberDialog from '$lib/components/MemberDialog.svelte';

	type HouseList = Awaited<ReturnType<typeof client.houses.list>>;

	let houses = $state<HouseList>([]);
	let view = $derived($page.url.searchParams.get('view') === 'chronicle' ? 'chronicle' : 'tree');
	let houseSlugs = $derived([...new Set($page.url.searchParams.getAll('house'))]);
	let selectedHouseNames = $derived(
		houses.filter((h) => houseSlugs.includes(h.slug)).map((h) => h.name)
	);
	let houseSelectionLabel = $derived(
		houseSlugs.length === 0
			? 'All Houses'
			: selectedHouseNames.length === 1
				? `House ${selectedHouseNames[0]}`
				: `${selectedHouseNames.length || houseSlugs.length} Houses`
	);
	let selectedMember = $derived($page.url.searchParams.get('member'));

	$effect(() => {
		client.houses
			.list()
			.then((h) => (houses = h))
			.catch(() => {});
	});

	function setView(next: 'tree' | 'chronicle') {
		const u = new URL($page.url);
		if (next === 'tree') u.searchParams.delete('view');
		else u.searchParams.set('view', next);
		goto(u, { keepFocus: true, noScroll: true });
	}
	function setHouses(slugs: string[]) {
		const u = new URL($page.url);
		u.searchParams.delete('house');
		for (const slug of slugs) u.searchParams.append('house', slug);
		u.searchParams.delete('member');
		goto(u, { keepFocus: true, noScroll: true });
	}
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
	<title
		>{view === 'chronicle'
			? 'The Chronicle'
			: houseSlugs.length
				? 'The Family Tree'
				: 'The Great Houses'} — Westeros Lineages</title
	>
</svelte:head>

<div class="relative h-full w-full overflow-hidden">
	<!-- Top controls: view toggle + house selector -->
	<div class="pointer-events-none absolute inset-x-0 top-0 z-20 flex items-start justify-between gap-3 p-3">
		<div
			class="pointer-events-auto flex gap-1 rounded-sm border border-white/10 bg-ink-soft/80 p-1 backdrop-blur-sm"
		>
			<button
				type="button"
				onclick={() => setView('tree')}
				class="rounded-sm px-4 py-1.5 font-display text-xs tracking-[0.15em] uppercase transition-colors {view ===
				'tree'
					? 'bg-gold/15 text-gold-bright'
					: 'text-ash/60 hover:text-gold'}"
			>
				Tree
			</button>
			<button
				type="button"
				onclick={() => setView('chronicle')}
				class="rounded-sm px-4 py-1.5 font-display text-xs tracking-[0.15em] uppercase transition-colors {view ===
				'chronicle'
					? 'bg-gold/15 text-gold-bright'
					: 'text-ash/60 hover:text-gold'}"
			>
				Chronicle
			</button>
		</div>

		<label class="pointer-events-auto max-w-[58vw]">
			<select
				multiple
				size="5"
				aria-label="Filter houses"
				onchange={(e) => {
					const selected = [...e.currentTarget.selectedOptions].map((option) => option.value);
					setHouses(selected.includes('') ? [] : selected);
				}}
				class="w-full min-w-40 rounded-sm border border-white/10 bg-ink-soft/90 px-3 py-2 font-display text-xs tracking-[0.15em] text-ash uppercase backdrop-blur-sm transition-colors hover:text-gold focus:border-gold/40 focus:outline-none sm:min-w-56"
			>
				<option value="" selected={houseSlugs.length === 0}>All Houses</option>
				{#each houses as h (h.slug)}
					<option value={h.slug} selected={houseSlugs.includes(h.slug)}>{h.name}</option>
				{/each}
			</select>
		</label>
	</div>

	<div class="box-border h-full w-full pt-44">
		{#if view === 'chronicle'}
			<Chronicle slugs={houseSlugs} {selectedMember} onSelect={selectMember} />
		{:else}
			{#key houseSlugs.join('|')}
				<FamilyTree slugs={houseSlugs} selectionLabel={houseSelectionLabel} {selectedMember} onSelect={selectMember} />
			{/key}
		{/if}
	</div>

	{#if selectedMember}
		<MemberDialog slug={selectedMember} onSelect={selectMember} onClose={closeMember} />
	{/if}
</div>
