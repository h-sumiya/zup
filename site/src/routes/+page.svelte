<script lang="ts">
	import { copy, localizedHref, localePreference } from '$lib/i18n';
</script>

<svelte:head>
	<title>{$copy.seo.homeTitle}</title>
	<meta name="description" content={$copy.seo.homeDescription} />
</svelte:head>

<section class="hero">
	<div class="hero-copy">
		<p class="badge">{$copy.hero.badge}</p>
		<h1>{$copy.hero.title}</h1>
		<p class="lead">{$copy.hero.description}</p>

		<div class="cta-row">
			<a
				class="btn btn-primary"
				href="https://github.com/h-sumiya/zup"
				target="_blank"
				rel="noreferrer"
			>
				{$copy.hero.ctaPrimary}
			</a>
			<a class="btn btn-secondary" href={localizedHref('/privacy/', $localePreference)}>
				{$copy.hero.ctaSecondary}
			</a>
		</div>

		<ul class="chips" aria-label="Highlights">
			{#each $copy.hero.chips as chip}
				<li>{chip}</li>
			{/each}
		</ul>
	</div>

	<figure class="hero-visual">
		<img
			src={$copy.gallery.items[0].src}
			alt={$copy.gallery.items[0].alt}
			loading="eager"
			decoding="async"
		/>
		<figcaption>{$copy.gallery.items[0].caption}</figcaption>
	</figure>
</section>

<section class="metrics" aria-label="Key values">
	{#each $copy.metrics as metric}
		<article>
			<p class="metric-value">{metric.value}</p>
			<p class="metric-label">{metric.label}</p>
		</article>
	{/each}
</section>

<section class="features">
	<header>
		<h2>{$copy.features.title}</h2>
		<p>{$copy.features.lead}</p>
	</header>
	<div class="feature-grid">
		{#each $copy.features.cards as feature}
			<article>
				<h3>{feature.title}</h3>
				<p>{feature.description}</p>
			</article>
		{/each}
	</div>
</section>

<section class="privacy-glance">
	<header>
		<h2>{$copy.privacy.title}</h2>
		<p>{$copy.privacy.lead}</p>
	</header>
	<ul>
		{#each $copy.privacy.bullets as bullet}
			<li>{bullet}</li>
		{/each}
	</ul>
	<a class="privacy-link" href={localizedHref('/privacy/', $localePreference)}>
		{$copy.hero.ctaSecondary}
	</a>
</section>

<section class="gallery">
	<header>
		<h2>{$copy.gallery.title}</h2>
		<p>{$copy.gallery.lead}</p>
	</header>

	<div class="gallery-grid">
		{#each $copy.gallery.items.slice(1) as item, index}
			<figure>
				<img
					src={item.src}
					alt={item.alt}
					loading={index === 0 ? 'eager' : 'lazy'}
					decoding="async"
				/>
				<figcaption>{item.caption}</figcaption>
			</figure>
		{/each}
	</div>
</section>

<style>
	.hero {
		display: grid;
		grid-template-columns: 1.08fr 0.92fr;
		gap: clamp(14px, 2.2vw, 28px);
		align-items: stretch;
		animation: rise-in 650ms ease both;
	}

	.hero-copy {
		display: flex;
		flex-direction: column;
		gap: 14px;
	}

	.badge {
		margin: 0;
		display: inline-flex;
		width: fit-content;
		padding: 5px 10px;
		border-radius: 999px;
		font-size: 0.76rem;
		font-weight: 700;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: #0a4b3c;
		background: linear-gradient(140deg, rgba(132, 236, 212, 0.56), rgba(252, 244, 188, 0.58));
		border: 1px solid rgba(10, 75, 60, 0.18);
	}

	h1 {
		margin: 0;
		font-size: clamp(2rem, 4.2vw, 3.55rem);
		line-height: 1.04;
		letter-spacing: -0.03em;
		text-wrap: balance;
	}

	.lead {
		margin: 0;
		font-size: clamp(0.96rem, 1.4vw, 1.08rem);
		line-height: 1.8;
		color: var(--ink-soft);
	}

	.cta-row {
		display: flex;
		gap: 10px;
		flex-wrap: wrap;
		margin-top: 8px;
	}

	.btn {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		height: 44px;
		padding: 0 18px;
		border-radius: 12px;
		text-decoration: none;
		font-weight: 700;
		font-size: 0.9rem;
		letter-spacing: 0.02em;
		transition:
			transform 170ms ease,
			box-shadow 170ms ease,
			background-color 170ms ease,
			color 170ms ease;
	}

	.btn:hover {
		transform: translateY(-2px);
	}

	.btn-primary {
		color: #fff;
		background: linear-gradient(145deg, #0f7f67 0%, #0b5f4d 100%);
		box-shadow: 0 14px 20px rgba(11, 95, 77, 0.24);
	}

	.btn-secondary {
		color: #1a2334;
		background: rgba(255, 255, 255, 0.68);
		border: 1px solid var(--line);
	}

	.chips {
		list-style: none;
		padding: 0;
		margin: 4px 0 0;
		display: flex;
		gap: 8px;
		flex-wrap: wrap;
	}

	.chips li {
		padding: 6px 10px;
		border-radius: 999px;
		font-size: 0.78rem;
		font-weight: 600;
		line-height: 1.2;
		background: var(--chip);
		border: 1px solid rgba(16, 20, 31, 0.09);
		color: #273043;
	}

	.hero-visual {
		margin: 0;
		display: flex;
		flex-direction: column;
		gap: 8px;
		padding: 10px;
		border-radius: 16px;
		background: rgba(255, 255, 255, 0.62);
		border: 1px solid var(--line);
		box-shadow: 0 14px 34px rgba(19, 27, 38, 0.14);
		transform: rotate(0.65deg);
		transition: transform 180ms ease;
	}

	.hero-visual:hover {
		transform: rotate(0deg) translateY(-2px);
	}

	.hero-visual img {
		display: block;
		width: 100%;
		border-radius: 10px;
		height: auto;
	}

	.hero-visual figcaption {
		margin: 0;
		font-size: 0.8rem;
		line-height: 1.5;
		color: var(--ink-soft);
	}

	.metrics {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		gap: 10px;
		animation: rise-in 720ms ease both;
		animation-delay: 80ms;
	}

	.metrics article {
		padding: 16px;
		border-radius: 14px;
		border: 1px solid var(--line);
		background: rgba(255, 255, 255, 0.64);
	}

	.metric-value {
		margin: 0;
		font-size: 1.08rem;
		font-weight: 700;
		letter-spacing: 0.01em;
	}

	.metric-label {
		margin: 7px 0 0;
		font-size: 0.82rem;
		line-height: 1.55;
		color: var(--ink-soft);
	}

	.features,
	.privacy-glance,
	.gallery {
		display: flex;
		flex-direction: column;
		gap: 16px;
	}

	.features header,
	.privacy-glance header,
	.gallery header {
		display: flex;
		flex-direction: column;
		gap: 8px;
	}

	h2 {
		margin: 0;
		font-size: clamp(1.28rem, 2.4vw, 1.82rem);
		letter-spacing: -0.01em;
	}

	h2 + p {
		margin: 0;
		line-height: 1.75;
		color: var(--ink-soft);
	}

	.feature-grid {
		display: grid;
		grid-template-columns: repeat(3, minmax(0, 1fr));
		gap: 10px;
	}

	.feature-grid article {
		padding: 18px;
		border-radius: 15px;
		border: 1px solid var(--line);
		background:
			linear-gradient(145deg, rgba(255, 255, 255, 0.82), rgba(251, 248, 241, 0.62)),
			repeating-linear-gradient(
				-35deg,
				rgba(15, 25, 41, 0.012),
				rgba(15, 25, 41, 0.012) 6px,
				transparent 6px,
				transparent 18px
			);
		box-shadow: 0 10px 22px rgba(15, 22, 37, 0.08);
	}

	.feature-grid h3 {
		margin: 0;
		font-size: 0.98rem;
		line-height: 1.45;
	}

	.feature-grid p {
		margin: 8px 0 0;
		font-size: 0.87rem;
		line-height: 1.65;
		color: var(--ink-soft);
	}

	.privacy-glance {
		padding: 20px;
		border-radius: 16px;
		border: 1px solid var(--line);
		background:
			linear-gradient(155deg, rgba(255, 255, 255, 0.82), rgba(241, 252, 246, 0.54)),
			repeating-linear-gradient(
				30deg,
				rgba(15, 25, 41, 0.013),
				rgba(15, 25, 41, 0.013) 5px,
				transparent 5px,
				transparent 16px
			);
	}

	.privacy-glance ul {
		margin: 0;
		padding-left: 1.2rem;
		display: grid;
		gap: 8px;
		line-height: 1.7;
		color: var(--ink-soft);
	}

	.privacy-glance li {
		padding-left: 2px;
	}

	.privacy-link {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		height: 40px;
		width: fit-content;
		padding: 0 14px;
		border-radius: 10px;
		text-decoration: none;
		font-size: 0.86rem;
		font-weight: 700;
		color: #0a4d3f;
		background: rgba(132, 236, 212, 0.38);
		border: 1px solid rgba(10, 77, 63, 0.2);
		transition: background-color 150ms ease;
	}

	.privacy-link:hover {
		background: rgba(132, 236, 212, 0.55);
	}

	.gallery-grid {
		display: grid;
		grid-template-columns: repeat(12, minmax(0, 1fr));
		gap: 10px;
	}

	.gallery-grid figure {
		margin: 0;
		grid-column: span 4;
		padding: 8px;
		border-radius: 12px;
		border: 1px solid var(--line);
		background: rgba(255, 255, 255, 0.68);
		transition:
			transform 150ms ease,
			box-shadow 150ms ease;
	}

	.gallery-grid figure:hover {
		transform: translateY(-3px);
		box-shadow: 0 16px 24px rgba(20, 30, 45, 0.11);
	}

	.gallery-grid img {
		display: block;
		width: 100%;
		height: auto;
		border-radius: 8px;
	}

	.gallery-grid figcaption {
		margin-top: 6px;
		font-size: 0.76rem;
		line-height: 1.45;
		color: var(--ink-soft);
	}

	@keyframes rise-in {
		from {
			opacity: 0;
			transform: translate3d(0, 10px, 0);
		}
		to {
			opacity: 1;
			transform: translate3d(0, 0, 0);
		}
	}

	@media (max-width: 980px) {
		.hero {
			grid-template-columns: 1fr;
		}

		.hero-visual {
			transform: none;
		}

		.metrics {
			grid-template-columns: repeat(2, minmax(0, 1fr));
		}

		.feature-grid {
			grid-template-columns: repeat(2, minmax(0, 1fr));
		}

		.gallery-grid figure {
			grid-column: span 6;
		}
	}

	@media (max-width: 640px) {
		.hero-copy {
			gap: 12px;
		}

		h1 {
			font-size: clamp(1.72rem, 9.2vw, 2.5rem);
		}

		.metrics,
		.feature-grid {
			grid-template-columns: 1fr;
		}

		.gallery-grid {
			grid-template-columns: repeat(6, minmax(0, 1fr));
		}

		.gallery-grid figure {
			grid-column: span 6;
		}
	}
</style>
