<script lang="ts">
	import { authClient } from '$lib/auth-client';
	import { goto } from '$app/navigation';

	const sessionQuery = authClient.useSession();

	async function handleSignOut() {
		await authClient.signOut({
		fetchOptions: {
			onSuccess: () => {
				goto('/');
			},
			onError: (error) => {
				console.error('Sign out failed:', error);
			}
		}
		});
	}

	function goToLogin() {
		goto('/login');
	}

</script>

<div class="relative">
	{#if $sessionQuery.isPending}
		<div class="h-8 w-24 animate-pulse rounded-sm bg-white/5"></div>
	{:else if $sessionQuery.data?.user}
		{@const user = $sessionQuery.data.user}
		<div class="flex items-center gap-3">
			<span class="hidden text-sm text-ash/70 sm:inline" title={user.email}>
				{user.name || user.email?.split('@')[0] || 'User'}
			</span>
			<button
				onclick={handleSignOut}
				class="rounded-sm border border-white/10 px-3 py-1 font-display text-xs tracking-[0.15em] text-ash/80 uppercase transition-colors hover:border-gold/40 hover:text-gold"
			>
				Sign Out
			</button>
		</div>
	{:else}
		<div class="flex items-center gap-2">
			<button
				onclick={goToLogin}
				class="rounded-sm border border-gold/40 px-3 py-1 font-display text-xs tracking-[0.15em] text-gold-bright uppercase transition-colors hover:border-gold"
			>
				Sign In
			</button>
		</div>
	{/if}
</div>
