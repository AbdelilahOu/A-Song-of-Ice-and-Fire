<script lang="ts">
	import { client } from '$lib/orpc';
	import { displayName, formatYear, lifespan } from '$lib/format';

	type Props = {
		slug: string;
		onSelect: (slug: string) => void;
		onClose: () => void;
	};
	let { slug, onSelect, onClose }: Props = $props();

	let member = $state<Awaited<ReturnType<typeof client.members.getBySlug>> | null>(null);
	let loading = $state(true);
	let notFound = $state(false);

	$effect(() => {
		const s = slug;
		loading = true;
		notFound = false;
		member = null;
		client.members
			.getBySlug({ slug: s })
			.then((m) => {
				if (m) member = m;
				else notFound = true;
				loading = false;
			})
			.catch(() => {
				notFound = true;
				loading = false;
			});
	});

	let spouses = $derived(
		member
			? [
					...member.marriagesAsA.map((m) => ({ ...m.spouseB, marriage: m })),
					...member.marriagesAsB.map((m) => ({ ...m.spouseA, marriage: m }))
				]
			: []
	);

	let children = $derived.by(() => {
		if (!member) return [];
		const all = [...member.childrenAsFather, ...member.childrenAsMother];
		const seen = new Set<number>();
		return all.filter((c) => (seen.has(c.id) ? false : (seen.add(c.id), true)));
	});

	const statusLabel: Record<string, string> = {
		alive: 'Alive',
		dead: 'Deceased',
		unknown: 'Fate unknown'
	};
</script>

<aside
	class="fixed inset-y-0 right-0 z-40 flex w-full max-w-md flex-col border-l border-white/10 bg-ink-soft/95 shadow-2xl backdrop-blur-md"
>
	<div class="flex items-center justify-between border-b border-white/10 px-5 py-4">
		<span class="font-display text-xs tracking-[0.3em] text-gold/70 uppercase">Member</span>
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
			<p class="text-ash/50">Consulting the maesters...</p>
		{:else if notFound || !member}
			<p class="text-ash/60">No record found for this member.</p>
		{:else}
			<header class="flex gap-4">
				<div class="relative shrink-0" style="width:84px; height:112px;">
					<div class="absolute inset-[14%] overflow-hidden">
						{#if member.portraitPath}
							<img src={member.portraitPath} alt="" class="h-full w-full object-cover" />
						{:else}
							<div
								class="flex h-full w-full items-center justify-center bg-ink/60 font-display text-2xl text-ash/30"
							>
								{member.name.charAt(0)}
							</div>
						{/if}
					</div>
					{#if member.house?.framePath}
						<img
							src={member.house.framePath}
							alt=""
							class="pointer-events-none relative block h-full w-full object-contain"
						/>
					{/if}
				</div>
				<div class="min-w-0">
					<h2 class="font-display text-xl leading-tight font-semibold text-gold-bright">
						{displayName(member)}
					</h2>
					{#if member.epithet}
						<p class="text-sm text-ash/70 italic">{member.epithet}</p>
					{/if}
					<p class="mt-2 text-xs tracking-wide text-ash/60 uppercase">
						{statusLabel[member.status] ?? member.status}
						{#if member.isBastard}· Bastard{/if}
					</p>
					<p class="text-xs text-ash/50">{lifespan(member.bornYear, member.diedYear)}</p>
				</div>
			</header>

			{#if member.house}
				<a
					href={`/house/${member.house.slug}`}
					class="mt-5 flex items-center gap-3 rounded-sm border border-white/10 bg-ink/60 px-3 py-2 transition-colors hover:border-gold/40"
				>
					{#if member.house.bannerPath}
						<img
							src={member.house.bannerPath}
							alt=""
							class="h-8 w-6 rounded-sm object-cover"
						/>
					{/if}
					<span class="font-display text-sm tracking-wide text-ash uppercase">
						House {member.house.name}
					</span>
				</a>
			{/if}

			{#if member.titles.length}
				{@render section('Titles')}
				<ul class="mb-4 space-y-1">
					{#each member.titles as t (t.id)}
						<li class="text-sm text-ash/80">
							{t.title}
							{#if t.startYear}<span class="text-ash/40">· {formatYear(t.startYear)}</span>{/if}
						</li>
					{/each}
				</ul>
			{/if}

			{#if member.father || member.mother}
				{@render section('Parents')}
				<div class="mb-4 flex flex-wrap gap-2">
					{#if member.father}{@render chip(member.father)}{/if}
					{#if member.mother}{@render chip(member.mother)}{/if}
				</div>
			{/if}

			{#if spouses.length}
				{@render section('Married to')}
				<div class="mb-4 flex flex-wrap gap-2">
					{#each spouses as s (s.id)}{@render chip(s)}{/each}
				</div>
			{/if}

			{#if children.length}
				{@render section('Children')}
				<div class="mb-4 flex flex-wrap gap-2">
					{#each children as c (c.id)}{@render chip(c)}{/each}
				</div>
			{/if}

			{#if member.bio}
				{@render section('History')}
				<p class="mb-4 text-sm leading-relaxed text-ash/75">{member.bio}</p>
			{/if}

			{#if member.death}
				{@render section('Death')}
				<div class="mb-4 rounded-sm border border-white/10 bg-ink/60 p-3 text-sm text-ash/75">
					<p>
						{member.death.cause}{member.death.year ? `, ${formatYear(member.death.year)}` : ''}{member
							.death.location
							? ` at ${member.death.location.name}`
							: ''}.
					</p>
					{#if member.death.description}
						<p class="mt-1 text-ash/60 italic">{member.death.description}</p>
					{/if}
					{#if member.death.killer}
						<p class="mt-2 text-xs text-ash/50">
							Slain by
							<button
								type="button"
								onclick={() => onSelect(member!.death!.killer!.slug)}
								class="text-gold/80 underline-offset-2 hover:underline"
							>
								{displayName(member.death.killer)}
							</button>
						</p>
					{/if}
				</div>
			{/if}
		{/if}
	</div>
</aside>

{#snippet section(label: string)}
	<h3 class="mt-5 mb-2 font-display text-xs tracking-[0.25em] text-gold/60 uppercase">
		{label}
	</h3>
{/snippet}

{#snippet chip(m: { slug: string; name: string; fullName: string | null; surname: string | null })}
	<button
		type="button"
		onclick={() => onSelect(m.slug)}
		class="rounded-sm border border-white/10 bg-ink/60 px-3 py-1.5 text-sm text-ash/80 transition-colors hover:border-gold/40 hover:text-gold-bright"
	>
		{displayName(m)}
	</button>
{/snippet}
