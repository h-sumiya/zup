<script lang="ts">
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
</svelte:head>

<div class="page">
	<main class="shell">
		<header class="header">
			<a class="brand" href="/">zup</a>
			<nav>
				<a href="/">Top</a>
				<a href="/privacy">Privacy Policy</a>
			</nav>
		</header>
		{@render children()}
	</main>
</div>

<style>
	:global(html, body) {
		margin: 0;
		padding: 0;
	}

	:global(body) {
		--bg: #f5f5f1;
		--surface: #ffffff;
		--text: #1e1f1a;
		--line: #d5d6cb;
		--link: #165a3f;
		font-family: 'Hiragino Kaku Gothic ProN', 'Yu Gothic', 'Noto Sans JP', sans-serif;
		background: radial-gradient(circle at top right, #f1efe4 0%, var(--bg) 42%, #efede4 100%);
		color: var(--text);
	}

	.page {
		min-height: 100svh;
		padding: 24px 16px;
		box-sizing: border-box;
	}

	.shell {
		max-width: 760px;
		margin: 0 auto;
		padding: 20px;
		border: 1px solid var(--line);
		background: color-mix(in srgb, var(--surface) 86%, #f4f2e7 14%);
		border-radius: 16px;
		box-shadow: 0 10px 24px rgba(31, 33, 25, 0.08);
	}

	.header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
		flex-wrap: wrap;
		margin-bottom: 24px;
	}

	.brand {
		font-size: 1.1rem;
		font-weight: 700;
		letter-spacing: 0.08em;
		text-transform: uppercase;
	}

	nav {
		display: flex;
		flex-wrap: wrap;
		gap: 14px;
	}

	a {
		color: var(--link);
		text-underline-offset: 3px;
		text-decoration-thickness: 1.2px;
	}
</style>
