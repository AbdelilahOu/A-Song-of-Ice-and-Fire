<script lang="ts">
	import SignInForm from '../../components/SignInForm.svelte';
	import SignUpForm from '../../components/SignUpForm.svelte';

	let showSignIn = $state(true);
</script>

<svelte:head>
	<title>{showSignIn ? 'Sign In' : 'Create Account'} — Westeros Lineages</title>
</svelte:head>

<section class="relative flex min-h-full flex-col items-center justify-center overflow-hidden px-4 py-16">
	<!-- Ambient frost glow -->
	<div
		class="pointer-events-none absolute top-[-10%] left-1/2 h-[520px] w-[520px] -translate-x-1/2 rounded-full bg-ember/10 blur-[120px]"
	></div>

	<div class="relative z-10 flex w-full flex-col items-center">
		{#if showSignIn}
			<SignInForm switchToSignUp={() => (showSignIn = false)} />
		{:else}
			<SignUpForm switchToSignIn={() => (showSignIn = true)} />
		{/if}
	</div>
</section>
