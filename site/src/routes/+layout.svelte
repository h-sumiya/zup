<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import favicon from '$lib/assets/favicon.svg';
	import {
		copy,
		initializeLocalePreference,
		localizedHref,
		localePreference,
		normalizeLocalePreference,
		setLocalePreference,
		type LocalePreference
	} from '$lib/i18n';
	import { onMount } from 'svelte';

	let { children } = $props();

	onMount(() => {
		initializeLocalePreference(page.url.searchParams);
	});

	$effect(() => {
		const queryPreference = normalizeLocalePreference(page.url.searchParams.get('lang'));
		if (queryPreference != null && queryPreference !== $localePreference) {
			setLocalePreference(queryPreference);
		}
	});

	async function handleLanguageChange(event: Event): Promise<void> {
		const select = event.currentTarget as HTMLSelectElement;
		const nextPreference = (normalizeLocalePreference(select.value) ?? 'auto') as LocalePreference;
		setLocalePreference(nextPreference);

		const nextUrl = new URL(page.url);
		if (nextPreference === 'auto') {
			nextUrl.searchParams.delete('lang');
		} else {
			nextUrl.searchParams.set('lang', nextPreference);
		}

		await goto(`${nextUrl.pathname}${nextUrl.search}${nextUrl.hash}`, {
			replaceState: true,
			noScroll: true,
			keepFocus: true
		});
	}
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
	<link
		href="https://fonts.googleapis.com/css2?family=Archivo+Black&family=IBM+Plex+Sans+JP:wght@400;500;700&family=Noto+Sans+SC:wght@400;500;700&display=swap"
		rel="stylesheet"
	/>
</svelte:head>

<div class="stage">
	<div class="orb orb-a" aria-hidden="true"></div>
	<div class="orb orb-b" aria-hidden="true"></div>
	<div class="page">
		<main class="shell">
			<header class="header">
				<a class="brand" href={localizedHref('/', $localePreference)} aria-label={$copy.brand.name}>
					<span class="brand-mark">{$copy.brand.name}</span>
					<span class="brand-line">{$copy.brand.tagline}</span>
				</a>

				<div class="header-controls">
					<nav aria-label="Primary">
						<a href={localizedHref('/', $localePreference)}>{$copy.nav.top}</a>
						<a href={localizedHref('/privacy/', $localePreference)}>{$copy.nav.privacy}</a>
						<a href="https://github.com/h-sumiya/zup" target="_blank" rel="noreferrer">
							{$copy.nav.github}
						</a>
					</nav>
					<label class="locale-picker" for="locale-picker">
						<span>{$copy.language.label}</span>
						<select id="locale-picker" value={$localePreference} onchange={handleLanguageChange}>
							<option value="auto">{$copy.language.options.auto}</option>
							<option value="ja">{$copy.language.options.ja}</option>
							<option value="en">{$copy.language.options.en}</option>
							<option value="zh">{$copy.language.options.zh}</option>
						</select>
					</label>
				</div>
			</header>

			{@render children()}

			<footer class="footer">
				<small>{$copy.footer.note}</small>
			</footer>
		</main>
	</div>
</div>

<style>
	:global(html, body) {
		margin: 0;
		min-height: 100%;
	}

	:global(body) {
		--bg-0: #f4f7f9;
		--bg-1: #dcebf0;
		--bg-2: #f8efdf;
		--ink: #10141f;
		--ink-soft: #50586d;
		--line: rgba(16, 20, 31, 0.14);
		--chip: rgba(16, 20, 31, 0.06);
		--surface: rgba(255, 255, 255, 0.77);
		--link: #0f6d59;
		--link-hover: #0a4d3f;
		font-family: 'IBM Plex Sans JP', 'Noto Sans SC', sans-serif;
		color: var(--ink);
		background:
			radial-gradient(1200px 780px at 85% -10%, #bbf3de 0%, transparent 63%),
			radial-gradient(900px 680px at -8% 14%, #ffdbc0 0%, transparent 65%),
			linear-gradient(165deg, var(--bg-1) 0%, var(--bg-0) 42%, var(--bg-2) 100%);
	}

	.stage {
		position: relative;
		min-height: 100svh;
		padding: 24px 16px 32px;
		overflow-x: clip;
	}

	.orb {
		position: absolute;
		pointer-events: none;
		filter: blur(52px);
		opacity: 0.44;
		z-index: 0;
	}

	.orb-a {
		top: 14%;
		right: -120px;
		width: 320px;
		height: 320px;
		background: #8cd0ff;
		animation: float-a 18s ease-in-out infinite;
	}

	.orb-b {
		bottom: 8%;
		left: -90px;
		width: 260px;
		height: 260px;
		background: #ffd9aa;
		animation: float-b 22s ease-in-out infinite;
	}

	.page {
		position: relative;
		z-index: 1;
		max-width: 1120px;
		margin: 0 auto;
	}

	.shell {
		display: flex;
		flex-direction: column;
		gap: 32px;
		padding: clamp(18px, 3.2vw, 38px);
		border: 1px solid var(--line);
		border-radius: 30px;
		background: linear-gradient(170deg, var(--surface) 0%, rgba(255, 255, 255, 0.62) 100%);
		box-shadow:
			0 28px 70px rgba(18, 24, 39, 0.16),
			inset 0 1px 0 rgba(255, 255, 255, 0.8);
		backdrop-filter: blur(5px);
	}

	.header {
		display: flex;
		align-items: flex-start;
		justify-content: space-between;
		gap: 20px;
		padding-bottom: 14px;
		border-bottom: 1px solid var(--line);
		flex-wrap: wrap;
	}

	.brand {
		display: inline-flex;
		flex-direction: column;
		gap: 2px;
		text-decoration: none;
		color: var(--ink);
		min-width: 220px;
	}

	.brand-mark {
		font-family: 'Archivo Black', 'IBM Plex Sans JP', sans-serif;
		font-size: clamp(1.25rem, 1.5vw, 1.6rem);
		letter-spacing: 0.1em;
		text-transform: uppercase;
	}

	.brand-line {
		font-size: 0.82rem;
		letter-spacing: 0.03em;
		color: var(--ink-soft);
	}

	.header-controls {
		display: flex;
		align-items: flex-end;
		gap: 14px;
		flex-wrap: wrap;
		justify-content: flex-end;
	}

	nav {
		display: flex;
		align-items: center;
		gap: 9px;
		flex-wrap: wrap;
	}

	nav a {
		display: inline-flex;
		align-items: center;
		height: 34px;
		padding: 0 12px;
		border-radius: 999px;
		text-decoration: none;
		font-size: 0.89rem;
		font-weight: 600;
		letter-spacing: 0.02em;
		color: var(--link);
		background: rgba(11, 83, 70, 0.08);
		border: 1px solid rgba(11, 83, 70, 0.18);
		transition:
			color 140ms ease,
			transform 140ms ease,
			background-color 140ms ease;
	}

	nav a:hover {
		transform: translateY(-1px);
		color: var(--link-hover);
		background: rgba(11, 83, 70, 0.16);
	}

	.locale-picker {
		display: inline-flex;
		flex-direction: column;
		gap: 5px;
		font-size: 0.74rem;
		letter-spacing: 0.02em;
		color: var(--ink-soft);
	}

	.locale-picker select {
		height: 34px;
		padding: 0 34px 0 10px;
		border-radius: 10px;
		border: 1px solid var(--line);
		background: #fff;
		font: inherit;
		font-size: 0.88rem;
		font-weight: 600;
		color: var(--ink);
		cursor: pointer;
	}

	.footer {
		border-top: 1px solid var(--line);
		padding-top: 16px;
		color: var(--ink-soft);
	}

	.footer small {
		font-size: 0.8rem;
		line-height: 1.6;
	}

	@keyframes float-a {
		0%,
		100% {
			transform: translate3d(0, 0, 0);
		}
		50% {
			transform: translate3d(-16px, 24px, 0);
		}
	}

	@keyframes float-b {
		0%,
		100% {
			transform: translate3d(0, 0, 0);
		}
		50% {
			transform: translate3d(28px, -20px, 0);
		}
	}

	@media (max-width: 760px) {
		.shell {
			padding: 18px;
			border-radius: 22px;
			gap: 24px;
		}

		.header {
			align-items: stretch;
			padding-bottom: 12px;
		}

		.header-controls {
			width: 100%;
			justify-content: flex-start;
		}

		nav a {
			height: 32px;
			font-size: 0.84rem;
		}
	}
</style>
