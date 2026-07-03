<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { client } from '$lib/orpc';
	import type { FeatureCollection } from 'geojson';

	type HouseList = Awaited<ReturnType<typeof client.houses.list>>;
	type EventList = Awaited<ReturnType<typeof client.map.eventsByHouse>>;
	type EventItem = EventList[number];

	const HOUSE_COLORS: Record<string, string> = {
		stark: '#8ea3b0',
		arryn: '#6ea2c9',
		tully: '#4f8a8b',
		lannister: '#9e2b3a',
		tyrell: '#5a8f4e',
		baratheon: '#caa03a',
		martell: '#c2703a',
		greyjoy: '#6b7f8c',
		targaryen: '#a33240'
	};
	const NEUTRAL_COLOR = '#3a444c';

	const EVENT_TYPE_COLORS: Record<string, string> = {
		battle: '#9e2b3a',
		war: '#7a2f2f',
		death: '#6b7280',
		coronation: '#caa03a',
		marriage: '#b06a8f',
		alliance: '#5a8f4e',
		betrayal: '#8a4fbf',
		founding: '#4f8a8b',
		dragon_hatching: '#c2703a',
		birth: '#6ea2c9',
		other: '#9fb2bf'
	};

	type RegionProps = { name: string; houseSlug: string | null };

	function slugify(s: string): string {
		return s
			.toLowerCase()
			.replace(/['’.]/g, '')
			.replace(/[^a-z0-9]+/g, '-')
			.replace(/^-+|-+$/g, '');
	}
	function formatYear(year: number): string {
		return year < 0 ? `${Math.abs(year)} BC` : `${year} AC`;
	}
	function escapeHtml(s: string): string {
		return s.replace(
			/[&<>"']/g,
			(c) =>
				({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c] as string
		);
	}
	function eventColor(type: string): string {
		return EVENT_TYPE_COLORS[type] ?? EVENT_TYPE_COLORS.other;
	}

	let mapEl = $state<HTMLDivElement>();
	let houses = $state<HouseList>([]);
	let events = $state<EventList>([]);
	let hovered = $state<string | null>(null);
	let ready = $state(false);
	let menuOpen = $state(true);

	// Non-reactive Leaflet handles.
	let Lmod: typeof import('leaflet');
	let map: import('leaflet').Map | undefined;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let geoLayer: any;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const regionLayerBySlug = new Map<string, any>();
	const regionCenterBySlug = new Map<string, [number, number]>();
	const placesBySlug = new Map<string, [number, number]>();
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let eventMarker: any = null;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let seatLayer: any = null;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let fullBounds: any;

	const houseBySlug = $derived(new Map(houses.map((h) => [h.slug, h])));
	const selectedSlug = $derived($page.url.searchParams.get('house'));
	const selectedEventSlug = $derived($page.url.searchParams.get('event'));
	const activeSlug = $derived(hovered ?? selectedSlug);
	const activeHouse = $derived(activeSlug ? houseBySlug.get(activeSlug) : undefined);
	const selectedEvent = $derived(events.find((e) => e.slug === selectedEventSlug));
	const locatedCount = $derived(events.filter((e) => e.location).length);

	function colorFor(slug: string | null): string {
		return (slug && HOUSE_COLORS[slug]) || NEUTRAL_COLOR;
	}

	function setHouse(slug: string | null) {
		const u = new URL($page.url);
		if (!slug || slug === selectedSlug) u.searchParams.delete('house');
		else u.searchParams.set('house', slug);
		u.searchParams.delete('event');
		goto(u, { keepFocus: true, noScroll: true });
	}
	function setEvent(slug: string | null) {
		const u = new URL($page.url);
		if (!slug || slug === selectedEventSlug) u.searchParams.delete('event');
		else u.searchParams.set('event', slug);
		goto(u, { keepFocus: true, noScroll: true });
	}

	function styleFor(slug: string | null) {
		const isActive = activeSlug === slug && slug !== null;
		const dim = activeSlug !== null && activeSlug !== slug;
		return {
			fillColor: colorFor(slug),
			fillOpacity: isActive ? 0.82 : dim ? 0.15 : 0.42,
			color: isActive ? '#eef4f7' : 'rgba(255,255,255,0.25)',
			weight: isActive ? 2 : 1
		};
	}

	function restyleRegions() {
		if (!geoLayer) return;
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		geoLayer.eachLayer((layer: any) => {
			const slug: string | null = layer.feature?.properties?.houseSlug ?? null;
			layer.setStyle(styleFor(slug));
			const el = layer.getElement?.();
			if (el) el.classList.toggle('region-selected', slug !== null && slug === selectedSlug);
		});
	}

	function resolveLatLng(ev: EventItem): [number, number] | undefined {
		if (ev.location) {
			const bySlug = placesBySlug.get(ev.location.slug);
			if (bySlug) return bySlug;
			const byName = placesBySlug.get(slugify(ev.location.name));
			if (byName) return byName;
		}
		return selectedSlug ? regionCenterBySlug.get(selectedSlug) : undefined;
	}

	function placeEventMarker(ev: EventItem | undefined) {
		if (!map || !Lmod) return;
		if (eventMarker) {
			map.removeLayer(eventMarker);
			eventMarker = null;
		}
		if (!ev) return;
		const ll = resolveLatLng(ev);
		if (!ll) return;
		const color = eventColor(ev.type);
		const icon = Lmod.divIcon({
			className: '',
			html: `<span class="event-pin" style="--c:${color}"></span>`,
			iconSize: [18, 18],
			iconAnchor: [9, 9]
		});
		const yr = ev.year != null ? formatYear(ev.year) : '';
		const html =
			`<div class="ev-pop"><strong>${escapeHtml(ev.name)}</strong>` +
			(yr ? `<div class="ev-yr">${yr}</div>` : '') +
			(ev.description ? `<p>${escapeHtml(ev.description)}</p>` : '') +
			(ev.location ? `<div class="ev-loc">${escapeHtml(ev.location.name)}</div>` : '') +
			`</div>`;
		eventMarker = Lmod.marker(ll, { icon, zIndexOffset: 1000 }).addTo(map);
		eventMarker.bindPopup(html, { className: 'westeros-popup' });
		eventMarker.openPopup();
		map.flyTo(ll, Math.max(map.getZoom(), 6), { duration: 0.6 });
	}

	// Load houses.
	$effect(() => {
		client.houses
			.list()
			.then((h) => (houses = h))
			.catch(() => {});
	});

	// Fetch a house's events whenever the selection changes.
	$effect(() => {
		const slug = selectedSlug;
		if (!slug) {
			events = [];
			return;
		}
		let cancelled = false;
		client.map
			.eventsByHouse({ slug })
			.then((r) => {
				if (!cancelled) events = r;
			})
			.catch(() => {
				if (!cancelled) events = [];
			});
		return () => {
			cancelled = true;
		};
	});

	// Restyle regions + marching-ants border on hover/selection change.
	$effect(() => {
		void activeSlug;
		void selectedSlug;
		if (ready) restyleRegions();
	});

	// Fly to the selected territory (or back to the full realm when cleared).
	$effect(() => {
		const slug = selectedSlug;
		if (!ready || !map) return;
		const layer = slug ? regionLayerBySlug.get(slug) : null;
		if (layer) map.flyToBounds(layer.getBounds(), { padding: [40, 40], maxZoom: 6, duration: 0.6 });
		else if (fullBounds) map.flyToBounds(fullBounds, { padding: [16, 16], duration: 0.6 });
	});

	// Place / move the event marker.
	$effect(() => {
		const ev = selectedEvent;
		if (ready) placeEventMarker(ev);
	});

	// Draw always-on house seat pins once houses + map are ready.
	$effect(() => {
		const hs = houses;
		if (!ready || !map || !Lmod || seatLayer || !hs.length) return;
		seatLayer = Lmod.layerGroup().addTo(map);
		for (const h of hs) {
			if (!HOUSE_COLORS[h.slug] || !h.seat) continue;
			const p = placesBySlug.get(slugify(h.seat));
			if (!p) continue;
			const icon = Lmod.divIcon({
				className: '',
				html: `<span class="seat-pin" style="--c:${HOUSE_COLORS[h.slug]}"></span>`,
				iconSize: [12, 12],
				iconAnchor: [6, 6]
			});
			const m = Lmod.marker(p, { icon }).addTo(seatLayer);
			m.bindTooltip(`${h.name} — ${h.seat}`, { direction: 'top', opacity: 0.9 });
			m.on('click', () => setHouse(h.slug));
		}
	});

	onMount(() => {
		let destroyed = false;
		(async () => {
			Lmod = await import('leaflet');
			await import('leaflet/dist/leaflet.css');
			if (destroyed || !mapEl) return;

			// Equirectangular CRS: source coords are pseudo lat/lng degrees.
			map = Lmod.map(mapEl, {
				crs: Lmod.CRS.EPSG4326,
				zoomControl: false,
				attributionControl: true,
				minZoom: 4,
				maxZoom: 8,
				zoomSnap: 0.25
			});
			map.attributionControl.setPrefix(false).setPosition('bottomleft');
			Lmod.control.zoom({ position: 'bottomright' }).addTo(map);

			const [regionRes, placeRes] = await Promise.all([
				fetch('/geo/westeros-political.geojson'),
				fetch('/geo/westeros-places.geojson')
			]);
			const regionData = (await regionRes.json()) as FeatureCollection;
			const placeData = (await placeRes.json()) as FeatureCollection;
			if (destroyed || !map) return;

			for (const f of placeData.features) {
				if (f.geometry.type !== 'Point') continue;
				const [lng, lat] = f.geometry.coordinates as [number, number];
				const slug = (f.properties as { slug: string }).slug;
				placesBySlug.set(slug, [lat, lng]);
			}

			geoLayer = Lmod.geoJSON(regionData, {
				style: (feature) => styleFor((feature?.properties as RegionProps)?.houseSlug ?? null),
				onEachFeature: (feature, layer) => {
					const props = feature.properties as RegionProps;
					if (props.houseSlug) regionLayerBySlug.set(props.houseSlug, layer);
					layer.on({
						mouseover: () => (hovered = props.houseSlug),
						mouseout: () => (hovered = null),
						click: () => {
							if (props.houseSlug) setHouse(props.houseSlug);
						}
					});
					layer.bindTooltip(props.name, { sticky: true, direction: 'top', opacity: 0.9 });
				}
			}).addTo(map);

			// eslint-disable-next-line @typescript-eslint/no-explicit-any
			geoLayer.eachLayer((layer: any) => {
				const slug: string | null = layer.feature?.properties?.houseSlug ?? null;
				if (slug) {
					const c = layer.getBounds().getCenter();
					regionCenterBySlug.set(slug, [c.lat, c.lng]);
				}
			});

			map.attributionControl.addAttribution(
				'Map data: cadaei, theMountainGoat &amp; Tear &middot; &copy; G.R.R. Martin &middot; ' +
					'<a href="https://creativecommons.org/licenses/by-nc-sa/3.0/" target="_blank" rel="noopener">CC BY-NC-SA 3.0</a>'
			);

			fullBounds = geoLayer.getBounds();
			map.invalidateSize();
			map.fitBounds(fullBounds, { padding: [16, 16] });
			map.setMaxBounds(fullBounds.pad(0.5));
			ready = true;
		})();

		return () => {
			destroyed = true;
			map?.remove();
			map = undefined;
		};
	});
</script>

<svelte:head>
	<title>The Map of Westeros — Westeros Lineages</title>
</svelte:head>

<div class="relative h-full w-full overflow-hidden">
	<div
		bind:this={mapEl}
		class="absolute inset-0"
		style="background:#0a0c0e;"
		aria-label="Interactive map of the territories of Westeros"
	></div>

	<!-- Floating house / events menu (collapsible to free up mobile space) -->
	<div class="pointer-events-none absolute inset-x-0 top-0 z-[1000] flex justify-start p-3">
		{#if menuOpen}
			<aside
				class="pointer-events-auto flex max-h-[calc(100%-1.5rem)] w-72 max-w-[calc(100vw-1.5rem)] flex-col rounded-sm border border-white/10 bg-ink-soft/85 shadow-2xl backdrop-blur-sm"
			>
				<div class="flex items-center justify-between gap-2 border-b border-white/5 px-4 py-3">
					<p class="min-w-0 truncate font-display text-xs tracking-[0.3em] text-ash/60 uppercase">
						{activeHouse ? `House ${activeHouse.name}` : 'The Great Houses'}
					</p>
					<div class="flex shrink-0 items-center gap-3">
						{#if selectedSlug}
							<button
								type="button"
								onclick={() => setHouse(null)}
								class="font-display text-xs tracking-[0.2em] text-ash/60 uppercase transition-colors hover:text-gold"
							>
								Back
							</button>
						{/if}
						<button
							type="button"
							onclick={() => (menuOpen = false)}
							aria-label="Hide menu"
							class="font-display text-xs tracking-[0.2em] text-ash/60 uppercase transition-colors hover:text-gold"
						>
							Hide
						</button>
					</div>
				</div>

				<div class="min-h-0 flex-1 overflow-y-auto">
					{#if activeHouse}
						<div class="border-b border-white/5 p-4">
							<p class="font-display text-xs tracking-[0.3em] text-gold/70 uppercase">
								{activeHouse.region ?? 'Westeros'}
							</p>
							{#if activeHouse.words}
								<p class="mt-2 font-display text-sm text-gold/80 italic">"{activeHouse.words}"</p>
							{/if}
							<div class="mt-4 flex flex-col gap-2">
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
						</div>

						{#if selectedSlug}
							<div class="p-4">
								<p class="font-display text-xs tracking-[0.3em] text-ash/50 uppercase">
									Events {events.length ? `(${events.length})` : ''}
								</p>
								{#if events.length === 0}
									<p class="mt-3 text-xs text-ash/40">No recorded events for this house.</p>
								{:else}
									<ul class="mt-3 flex flex-col gap-1">
										{#each events as ev (ev.id)}
											<li>
												<button
													type="button"
													onclick={() => setEvent(ev.slug)}
													class="w-full rounded-sm px-2 py-1.5 text-left transition-colors hover:bg-white/5 {selectedEventSlug ===
													ev.slug
														? 'bg-white/10'
														: ''}"
												>
													<span class="flex items-center gap-2">
														<span
															class="h-2 w-2 shrink-0 rounded-full"
															style={`background:${eventColor(ev.type)}`}
														></span>
														<span class="min-w-0 flex-1 truncate text-sm text-ash/80">{ev.name}</span>
														{#if ev.year != null}
															<span class="shrink-0 text-xs text-ash/40">{formatYear(ev.year)}</span>
														{/if}
													</span>
													{#if !ev.location}
														<span class="mt-0.5 block pl-4 text-[10px] text-ash/30 uppercase">
															approx. location
														</span>
													{/if}
												</button>
											</li>
										{/each}
									</ul>
									{#if locatedCount < events.length}
										<p class="mt-3 text-[10px] text-ash/30">
											{locatedCount} of {events.length} placed precisely; others show near the region.
										</p>
									{/if}
								{/if}
							</div>
						{/if}
					{:else}
						<div class="p-4">
							<p class="font-display text-xs tracking-[0.3em] text-ash/50 uppercase">
								The Great Houses
							</p>
							<ul class="mt-3 flex flex-col gap-0.5">
								{#each houses.filter((h) => HOUSE_COLORS[h.slug]) as h (h.slug)}
									<li>
										<button
											type="button"
											onmouseenter={() => (hovered = h.slug)}
											onmouseleave={() => (hovered = null)}
											onclick={() => setHouse(h.slug)}
											class="flex w-full items-center gap-2.5 rounded-sm px-2 py-1.5 text-left text-sm text-ash/75 transition-colors hover:bg-white/5 hover:text-gold-bright"
										>
											<span
												class="h-2.5 w-2.5 shrink-0 rounded-full"
												style={`background:${colorFor(h.slug)}`}
											></span>
											<span class="font-display tracking-wide">{h.name}</span>
											<span class="ml-auto truncate text-xs text-ash/40">{h.region ?? ''}</span>
										</button>
									</li>
								{/each}
							</ul>
							<p class="mt-3 text-xs text-ash/40">Select a region to see its house and events.</p>
						</div>
					{/if}
				</div>
			</aside>
		{:else}
			<button
				type="button"
				onclick={() => (menuOpen = true)}
				class="pointer-events-auto rounded-sm border border-white/10 bg-ink-soft/85 px-4 py-2 font-display text-xs tracking-[0.2em] text-ash uppercase shadow-2xl backdrop-blur-sm transition-colors hover:text-gold"
			>
				{activeHouse ? `House ${activeHouse.name}` : 'Houses'}
			</button>
		{/if}
	</div>
</div>

<style>
	:global(.leaflet-container) {
		background: #0a0c0e;
		font-family: inherit;
	}
	/* Remove the focus-box rectangle that appears around a tapped region/map. */
	:global(.leaflet-container:focus),
	:global(.leaflet-container:focus-visible),
	:global(.leaflet-interactive:focus),
	:global(.leaflet-interactive:focus-visible),
	:global(.leaflet-interactive) {
		outline: none;
	}
	:global(.seat-pin) {
		display: block;
		width: 10px;
		height: 10px;
		border-radius: 9999px;
		background: var(--c);
		border: 2px solid rgba(0, 0, 0, 0.65);
		box-shadow: 0 0 6px rgba(0, 0, 0, 0.6);
	}
	:global(.event-pin) {
		display: block;
		width: 14px;
		height: 14px;
		border-radius: 9999px;
		background: var(--c);
		border: 2px solid #eef4f7;
		box-shadow: 0 0 0 4px color-mix(in srgb, var(--c) 40%, transparent);
		animation: -global-event-pulse 1.6s ease-in-out infinite;
	}
	@keyframes -global-event-pulse {
		0%,
		100% {
			box-shadow: 0 0 0 3px color-mix(in srgb, var(--c) 45%, transparent);
		}
		50% {
			box-shadow: 0 0 0 7px color-mix(in srgb, var(--c) 10%, transparent);
		}
	}
	:global(.region-selected) {
		stroke-dasharray: 6 6;
		animation: -global-region-march 1s linear infinite;
	}
	@keyframes -global-region-march {
		to {
			stroke-dashoffset: -12;
		}
	}
	:global(.westeros-popup .leaflet-popup-content-wrapper) {
		background: #14181c;
		color: #a7b2b9;
		border: 1px solid rgba(255, 255, 255, 0.12);
		border-radius: 2px;
	}
	:global(.westeros-popup .leaflet-popup-tip) {
		background: #14181c;
		border: 1px solid rgba(255, 255, 255, 0.12);
	}
	:global(.westeros-popup a.leaflet-popup-close-button) {
		color: #a7b2b9;
	}
	:global(.westeros-popup .ev-pop strong) {
		color: #d9e6ee;
		font-family: 'Cinzel', serif;
	}
	:global(.westeros-popup .ev-pop .ev-yr) {
		color: #9fb2bf;
		font-size: 11px;
		letter-spacing: 0.1em;
		margin-top: 2px;
	}
	:global(.westeros-popup .ev-pop p) {
		margin: 6px 0 0;
		font-size: 12px;
		line-height: 1.4;
	}
	:global(.westeros-popup .ev-pop .ev-loc) {
		margin-top: 6px;
		font-size: 10px;
		text-transform: uppercase;
		letter-spacing: 0.15em;
		color: #9fb2bf;
	}
</style>
