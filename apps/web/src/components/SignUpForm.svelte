<script lang="ts">
	import { createForm } from '@tanstack/svelte-form';
	import { z } from 'zod';
	import { authClient } from '$lib/auth-client';
	import { goto } from '$app/navigation';

	let { switchToSignIn } = $props<{ switchToSignIn: () => void }>();

	let formError = $state('');

	const validationSchema = z.object({
		name: z.string().min(2, 'Name must be at least 2 characters'),
		email: z.email('Invalid email address'),
		password: z.string().min(8, 'Password must be at least 8 characters'),
	});

	const form = createForm(() => ({
		defaultValues: { name: '', email: '', password: '' },
		onSubmit: async ({ value }) => {
			formError = '';
			await authClient.signUp.email(
				{
					email: value.email,
					password: value.password,
					name: value.name,
				},
				{
					onSuccess: () => {
						goto('/dashboard');
					},
					onError: (error) => {
						formError = error.error.message || 'Sign up failed. Please try again.';
					},
				}
			);
		},
		validators: {
			onSubmit: validationSchema,
		},
	}));

	type SubmitState = Pick<typeof form.state, 'canSubmit' | 'isSubmitting'>;

	const inputClass =
		'w-full border border-white/10 bg-ink-soft/60 px-3 py-2.5 text-ash transition-colors placeholder:text-ash/25 focus:border-gold/50 focus:outline-none focus:ring-1 focus:ring-gold/20';
	const labelClass = 'block font-display text-xs tracking-[0.2em] text-ash/60 uppercase';
</script>

<div class="w-full max-w-md">
	<div
		class="relative overflow-hidden border border-white/10 bg-gradient-to-b from-blood/40 to-ink/60 p-8 backdrop-blur-sm shadow-[0_0_60px_-20px_rgba(140,170,195,0.25)]"
	>
		<!-- Ambient glow inside the card -->
		<div
			class="pointer-events-none absolute top-[-30%] left-1/2 h-64 w-64 -translate-x-1/2 rounded-full bg-ember/15 blur-[90px]"
		></div>

		<div class="relative z-10">
			<div class="mb-8 text-center">
				<span class="font-display text-xs tracking-[0.4em] text-gold/70 uppercase">
					Swear Your Oath
				</span>
				<h1
					class="mt-3 font-display text-3xl font-semibold text-transparent uppercase"
					style="background: linear-gradient(180deg, #eef4f7 0%, #9fb2bf 70%, #55636d 100%); -webkit-background-clip: text; background-clip: text;"
				>
					Create Account
				</h1>
				<div class="mx-auto mt-4 flex items-center justify-center gap-3">
					<span class="h-px w-10 bg-gradient-to-r from-transparent to-gold/30"></span>
					<span class="text-[10px] tracking-[0.3em] text-ash/40 uppercase">Westeros</span>
					<span class="h-px w-10 bg-gradient-to-l from-transparent to-gold/30"></span>
				</div>
			</div>

			<form
				id="form"
				class="space-y-5"
				onsubmit={(e) => {
					e.preventDefault();
					e.stopPropagation();
					form.handleSubmit();
				}}
			>
				<form.Field name="name">
					{#snippet children(field)}
						<div class="space-y-1.5">
							<label class={labelClass} for={field.name}>Name</label>
							<input
								id={field.name}
								name={field.name}
								autocomplete="name"
								class={inputClass}
								onblur={field.handleBlur}
								value={field.state.value}
								oninput={(e: Event) => {
									const target = e.target as HTMLInputElement;
									field.handleChange(target.value);
								}}
							/>
							{#if field.state.meta.isTouched}
								{#each field.state.meta.errors as error}
									<p class="text-sm text-red-400/90" role="alert">{error}</p>
								{/each}
							{/if}
						</div>
					{/snippet}
				</form.Field>

				<form.Field name="email">
					{#snippet children(field)}
						<div class="space-y-1.5">
							<label class={labelClass} for={field.name}>Email</label>
							<input
								id={field.name}
								name={field.name}
								type="email"
								autocomplete="email"
								class={inputClass}
								onblur={field.handleBlur}
								value={field.state.value}
								oninput={(e: Event) => {
									const target = e.target as HTMLInputElement;
									field.handleChange(target.value);
								}}
							/>
							{#if field.state.meta.isTouched}
								{#each field.state.meta.errors as error}
									<p class="text-sm text-red-400/90" role="alert">{error}</p>
								{/each}
							{/if}
						</div>
					{/snippet}
				</form.Field>

				<form.Field name="password">
					{#snippet children(field)}
						<div class="space-y-1.5">
							<label class={labelClass} for={field.name}>Password</label>
							<input
								id={field.name}
								name={field.name}
								type="password"
								autocomplete="new-password"
								class={inputClass}
								onblur={field.handleBlur}
								value={field.state.value}
								oninput={(e: Event) => {
									const target = e.target as HTMLInputElement;
									field.handleChange(target.value);
								}}
							/>
							{#if field.state.meta.isTouched}
								{#each field.state.meta.errors as error}
									<p class="text-sm text-red-400/90" role="alert">{error}</p>
								{/each}
							{/if}
						</div>
					{/snippet}
				</form.Field>

				{#if formError}
					<p
						class="border border-red-500/20 bg-red-500/5 px-3 py-2 text-sm text-red-400/90"
						role="alert"
					>
						{formError}
					</p>
				{/if}

				<form.Subscribe
					selector={(state: typeof form.state): SubmitState => ({
						canSubmit: state.canSubmit,
						isSubmitting: state.isSubmitting,
					})}
				>
					{#snippet children(state: SubmitState)}
						<button
							type="submit"
							disabled={!state.canSubmit || state.isSubmitting}
							class="group relative inline-flex w-full items-center justify-center border border-gold/40 bg-gradient-to-b from-blood/60 to-ink px-8 py-3 font-display text-sm tracking-[0.2em] text-gold-bright uppercase transition-all hover:border-gold hover:from-blood hover:shadow-[0_0_30px_-6px_rgba(140,170,195,0.5)] disabled:cursor-not-allowed disabled:opacity-50 disabled:hover:border-gold/40 disabled:hover:shadow-none"
						>
							{state.isSubmitting ? 'Swearing...' : 'Sign Up'}
						</button>
					{/snippet}
				</form.Subscribe>
			</form>

			<div class="mt-6 text-center">
				<button
					type="button"
					class="font-display text-xs tracking-[0.2em] text-ash/50 uppercase transition-colors hover:text-gold"
					onclick={switchToSignIn}
				>
					Already have an account? Sign In
				</button>
			</div>
		</div>
	</div>
</div>
