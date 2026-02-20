<script lang="ts">
	import { copy, localizedHref, localePreference } from '$lib/i18n';
</script>

<svelte:head>
	<title>{$copy.seo.privacyTitle}</title>
	<meta name="description" content={$copy.seo.privacyDescription} />
</svelte:head>

<article class="policy">
	<p class="eyebrow">{$copy.nav.privacy}</p>
	<h1>{$copy.privacy.title}</h1>
	<p class="lead">{$copy.privacy.lead}</p>
	<ul>
		{#each $copy.privacy.bullets as bullet}
			<li>{bullet}</li>
		{/each}
	</ul>
	<p class="effective">{$copy.privacy.effectiveDate}</p>
	<div class="actions">
		<a href="https://github.com/h-sumiya/zup" target="_blank" rel="noreferrer"
			>{$copy.privacy.repoCta}</a
		>
		<a href={localizedHref('/', $localePreference)}>{$copy.nav.top}</a>
	</div>
</article>

<style>
	.policy {
		max-width: 760px;
		padding: clamp(16px, 2.8vw, 28px);
		border-radius: 18px;
		border: 1px solid var(--line);
		background:
			linear-gradient(165deg, rgba(255, 255, 255, 0.85), rgba(250, 251, 255, 0.63)),
			repeating-linear-gradient(
				130deg,
				rgba(15, 24, 38, 0.015),
				rgba(15, 24, 38, 0.015) 7px,
				transparent 7px,
				transparent 18px
			);
		box-shadow: 0 16px 36px rgba(16, 24, 39, 0.12);
		animation: appear 500ms ease both;
	}

	.eyebrow {
		margin: 0;
		display: inline-flex;
		padding: 4px 9px;
		border-radius: 999px;
		font-size: 0.73rem;
		letter-spacing: 0.07em;
		text-transform: uppercase;
		font-weight: 700;
		color: #0a4b3c;
		background: rgba(132, 236, 212, 0.42);
		border: 1px solid rgba(10, 75, 60, 0.2);
	}

	h1 {
		margin: 12px 0 10px;
		font-size: clamp(1.52rem, 3.7vw, 2.28rem);
		letter-spacing: -0.02em;
	}

	.lead {
		margin: 0;
		line-height: 1.8;
		color: var(--ink-soft);
	}

	ul {
		margin: 14px 0 0;
		padding-left: 1.2rem;
		display: grid;
		gap: 8px;
		line-height: 1.8;
	}

	li {
		padding-left: 2px;
	}

	.effective {
		margin: 16px 0 0;
		padding-top: 14px;
		border-top: 1px dashed var(--line);
		font-weight: 600;
	}

	.actions {
		margin-top: 16px;
		display: flex;
		gap: 10px;
		flex-wrap: wrap;
	}

	.actions a {
		display: inline-flex;
		align-items: center;
		height: 36px;
		padding: 0 12px;
		border-radius: 10px;
		text-decoration: none;
		font-size: 0.87rem;
		font-weight: 600;
		color: var(--link);
		background: rgba(15, 109, 89, 0.09);
		border: 1px solid rgba(15, 109, 89, 0.17);
		transition: background-color 150ms ease;
	}

	.actions a:hover {
		background: rgba(15, 109, 89, 0.16);
	}

	@keyframes appear {
		from {
			opacity: 0;
			transform: translate3d(0, 8px, 0);
		}
		to {
			opacity: 1;
			transform: translate3d(0, 0, 0);
		}
	}
</style>
