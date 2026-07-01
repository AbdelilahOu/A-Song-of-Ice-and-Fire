<script lang="ts">
	import UserMenu from './UserMenu.svelte';

	let open = $state(false);
</script>

<header class="relative border-b border-white/5 bg-ink/60 px-4 py-3 backdrop-blur-sm md:px-8">
	<div class="flex flex-row items-center justify-between">
		<a href="/" class="group flex items-center gap-3">
			<span
				class="font-display text-lg font-semibold tracking-[0.2em] text-gold uppercase transition-colors group-hover:text-gold-bright"
			>
				Westeros
			</span>
			<span class="hidden text-xs tracking-[0.35em] text-ash/50 uppercase sm:inline">
				Lineages
			</span>
		</a>

		<nav class="hidden items-center gap-6 font-display text-xs tracking-[0.2em] uppercase md:flex">
			<a href="/" class="text-ash/80 transition-colors hover:text-gold">Home</a>
			<a href="/tree" class="text-ash/80 transition-colors hover:text-gold">The Tree</a>
			<a href="/dashboard" class="text-ash/80 transition-colors hover:text-gold">Dashboard</a>
			<UserMenu />
		</nav>

		<button
			type="button"
			onclick={() => (open = !open)}
			aria-expanded={open}
			aria-controls="mobile-nav"
			class="font-display text-xs tracking-[0.2em] text-ash/80 uppercase transition-colors hover:text-gold md:hidden"
		>
			{open ? 'Close' : 'Menu'}
		</button>
	</div>

	{#if open}
		<nav
			id="mobile-nav"
			class="mt-3 flex flex-col gap-4 border-t border-white/5 pt-4 font-display text-sm tracking-[0.2em] uppercase md:hidden"
		>
			<a href="/" onclick={() => (open = false)} class="text-ash/80 transition-colors hover:text-gold">
				Home
			</a>
			<a href="/tree" onclick={() => (open = false)} class="text-ash/80 transition-colors hover:text-gold">
				The Tree
			</a>
			<a
				href="/dashboard"
				onclick={() => (open = false)}
				class="text-ash/80 transition-colors hover:text-gold"
			>
				Dashboard
			</a>
			<div class="pt-1">
				<UserMenu />
			</div>
		</nav>
	{/if}
</header>
