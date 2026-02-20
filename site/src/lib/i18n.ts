import { browser } from '$app/environment';
import { derived, get, writable } from 'svelte/store';

export const supportedLocales = ['ja', 'en', 'zh'] as const;

export type SupportedLocale = (typeof supportedLocales)[number];
export type LocalePreference = SupportedLocale | 'auto';

type Metric = {
	label: string;
	value: string;
};

type Feature = {
	description: string;
	title: string;
};

type GalleryItem = {
	alt: string;
	caption: string;
	src: string;
};

type LanguageOptionLabels = Record<LocalePreference, string>;

export type SiteCopy = {
	brand: {
		name: string;
		tagline: string;
	};
	features: {
		cards: Feature[];
		lead: string;
		title: string;
	};
	footer: {
		note: string;
	};
	gallery: {
		items: GalleryItem[];
		lead: string;
		title: string;
	};
	hero: {
		badge: string;
		chips: string[];
		ctaPrimary: string;
		ctaSecondary: string;
		description: string;
		title: string;
	};
	language: {
		label: string;
		options: LanguageOptionLabels;
	};
	metrics: Metric[];
	nav: {
		github: string;
		privacy: string;
		top: string;
	};
	privacy: {
		bullets: string[];
		effectiveDate: string;
		lead: string;
		repoCta: string;
		title: string;
	};
	seo: {
		homeDescription: string;
		homeTitle: string;
		privacyDescription: string;
		privacyTitle: string;
	};
};

const fallbackLocale: SupportedLocale = 'en';
const storageKey = 'zup-site-locale-preference';

const translations: Record<SupportedLocale, SiteCopy> = {
	en: {
		brand: {
			name: 'zup',
			tagline: 'Desktop ZIP updater for GitHub Releases'
		},
		features: {
			cards: [
				{
					title: 'Repository-driven source control',
					description:
						'Register each app by GitHub repository URL and keep update logic predictable per source.'
				},
				{
					title: 'Regex asset selection',
					description:
						'Use ZIP filename patterns to target the right artifact even when release assets include extras.'
				},
				{
					title: 'Ready for private repos',
					description:
						'Optional GitHub Personal Access Token support unlocks higher API limits and private repository access.'
				}
			],
			lead: 'A pragmatic updater flow designed for ZIP-based desktop distribution.',
			title: 'What makes zup practical'
		},
		footer: {
			note: 'zup runs locally on your machine and does not collect telemetry.'
		},
		gallery: {
			items: [
				{
					src: '/screenshots/hero.png',
					alt: 'Zup app introduction hero visual',
					caption: 'Hero: app introduction visual.'
				},
				{
					src: '/screenshots/01.png',
					alt: 'Zup list screen',
					caption: '1. List screen'
				},
				{
					src: '/screenshots/02.png',
					alt: 'Zup add screen',
					caption: '2. Add screen'
				},
				{
					src: '/screenshots/03.png',
					alt: 'Zup detail screen',
					caption: '3. Detail screen'
				}
			],
			lead: 'Hero visual plus key app screens used in the README.',
			title: 'Hero and UI screens'
		},
		hero: {
			badge: 'GitHub Releases ZIP Updater',
			chips: ['ZIP-focused workflow', 'English / Japanese / Chinese', 'No telemetry collection'],
			ctaPrimary: 'View GitHub Repository',
			ctaSecondary: 'Read Privacy Policy',
			description:
				'Register a repository URL and ZIP rule once, then keep your desktop apps current with one reliable flow.',
			title: 'One control panel for ZIP-distributed app updates.'
		},
		language: {
			label: 'Language',
			options: {
				auto: 'Auto',
				ja: 'Japanese',
				en: 'English',
				zh: 'Chinese'
			}
		},
		metrics: [
			{
				value: 'ZIP Assets',
				label: 'Purpose-built for release ZIP files'
			},
			{
				value: '3 Languages',
				label: 'English, Japanese, Chinese in the app and this site'
			},
			{
				value: '0 Analytics',
				label: 'No analytics or behavior tracking in the app'
			}
		],
		nav: {
			github: 'GitHub',
			privacy: 'Privacy',
			top: 'Top'
		},
		privacy: {
			bullets: [
				'Registered repository info, install paths, language choice, and optional GitHub token are stored locally on your device.',
				'Network access occurs only when you trigger release checks, installs, or updates, targeting GitHub API and asset download URLs.',
				'The developer does not run analytics, ad trackers, or external data brokers for the app.'
			],
			effectiveDate: 'Effective date: February 20, 2026',
			lead: 'zup is a local desktop app and does not send usage telemetry to the developer.',
			repoCta: 'Project repository and source code',
			title: 'Privacy Policy'
		},
		seo: {
			homeDescription:
				'zup is a local-first desktop updater for ZIP assets on GitHub Releases with English, Japanese, and Chinese localization.',
			homeTitle: 'zup | Desktop ZIP Updater',
			privacyDescription: 'App privacy policy for zup desktop updater.',
			privacyTitle: 'Privacy Policy | zup'
		}
	},
	ja: {
		brand: {
			name: 'zup',
			tagline: 'GitHub Releases 向けデスクトップ ZIP アップデーター'
		},
		features: {
			cards: [
				{
					title: 'リポジトリ単位で明確に管理',
					description:
						'アプリごとに GitHub リポジトリ URL を登録し、更新ルールをソース単位で安定運用できます。'
				},
				{
					title: '正規表現で ZIP を選別',
					description:
						'アセットが複数あるリリースでも、ZIP ファイル名ルールで必要な成果物だけを確実に拾えます。'
				},
				{
					title: 'プライベートリポジトリにも対応',
					description:
						'GitHub Personal Access Token を任意で設定すれば、API 制限の緩和や private repo 取得に対応できます。'
				}
			],
			lead: 'ZIP 配布のデスクトップ更新運用に合わせた、無駄のないフロー。',
			title: 'zup の実用ポイント'
		},
		footer: {
			note: 'zup はローカルで動作し、利用状況テレメトリを収集しません。'
		},
		gallery: {
			items: [
				{
					src: '/screenshots/hero.png',
					alt: 'Zup アプリ紹介 Hero ビジュアル',
					caption: 'Hero: アプリ紹介ビジュアル。'
				},
				{
					src: '/screenshots/01.png',
					alt: 'Zup 一覧画面',
					caption: '1. 一覧画面'
				},
				{
					src: '/screenshots/02.png',
					alt: 'Zup 追加画面',
					caption: '2. 追加画面'
				},
				{
					src: '/screenshots/03.png',
					alt: 'Zup 詳細画面',
					caption: '3. 詳細画面'
				}
			],
			lead: 'README で使用している Hero ビジュアルと主要画面を掲載しています。',
			title: 'Hero と画面イメージ'
		},
		hero: {
			badge: 'GitHub Releases ZIP Updater',
			chips: ['ZIP 配布に特化', '英語・日本語・中国語', 'テレメトリ収集なし'],
			ctaPrimary: 'GitHub リポジトリを見る',
			ctaSecondary: 'プライバシーポリシー',
			description:
				'GitHub リポジトリ URL と ZIP ルールを登録するだけで、デスクトップアプリの更新導線を一箇所に集約できます。',
			title: 'ZIP 配布アプリの更新を、ひとつの管理画面へ。'
		},
		language: {
			label: '表示言語',
			options: {
				auto: '自動',
				ja: '日本語',
				en: '英語',
				zh: '中国語'
			}
		},
		metrics: [
			{
				value: 'ZIP 特化',
				label: 'GitHub Releases の ZIP 配布に最適化'
			},
			{
				value: '3 言語',
				label: 'アプリと同じ英語・日本語・中国語に対応'
			},
			{
				value: '解析なし',
				label: 'アプリ利用の追跡・行動分析を行いません'
			}
		],
		nav: {
			github: 'GitHub',
			privacy: 'プライバシー',
			top: 'トップ'
		},
		privacy: {
			bullets: [
				'登録したリポジトリ情報、インストール先、言語設定、任意の GitHub Token は端末内に保存されます。',
				'通信は、利用者が更新確認・インストール・更新を実行したときに、GitHub API とアセット取得先に対してのみ行われます。',
				'アプリ向けのアクセス解析、広告トラッキング、外部データ販売は行いません。'
			],
			effectiveDate: '適用開始日: 2026年2月20日',
			lead: 'zup はローカル実行のデスクトップアプリであり、開発者への利用テレメトリ送信を行いません。',
			repoCta: 'プロジェクトリポジトリとソースコード',
			title: 'プライバシーポリシー'
		},
		seo: {
			homeDescription:
				'zup は GitHub Releases の ZIP 配布アプリ向けローカル実行デスクトップアップデーターです。英語・日本語・中国語に対応しています。',
			homeTitle: 'zup | デスクトップ ZIP アップデーター',
			privacyDescription: 'zup デスクトップアプリのプライバシーポリシー',
			privacyTitle: 'プライバシーポリシー | zup'
		}
	},
	zh: {
		brand: {
			name: 'zup',
			tagline: '面向 GitHub Releases 的桌面 ZIP 更新工具'
		},
		features: {
			cards: [
				{
					title: '按仓库来源精确管理',
					description: '每个应用都以 GitHub 仓库 URL 为单位登记，更新策略清晰稳定，便于长期维护。'
				},
				{
					title: '正则筛选 ZIP 资源',
					description: '当一次发布包含多个附件时，可用 ZIP 文件名规则精准选择目标安装包。'
				},
				{
					title: '支持私有仓库场景',
					description: '可选配置 GitHub Personal Access Token，以获得更高 API 限额并访问私有仓库。'
				}
			],
			lead: '为 ZIP 分发型桌面应用准备的高效更新流程。',
			title: 'zup 的核心能力'
		},
		footer: {
			note: 'zup 在本地运行，不收集使用遥测数据。'
		},
		gallery: {
			items: [
				{
					src: '/screenshots/hero.png',
					alt: 'Zup 应用介绍 Hero 视觉图',
					caption: 'Hero：应用介绍视觉图。'
				},
				{
					src: '/screenshots/01.png',
					alt: 'Zup 列表界面',
					caption: '1. 列表界面'
				},
				{
					src: '/screenshots/02.png',
					alt: 'Zup 添加界面',
					caption: '2. 添加界面'
				},
				{
					src: '/screenshots/03.png',
					alt: 'Zup 详情界面',
					caption: '3. 详情界面'
				}
			],
			lead: '这里展示 README 使用的 Hero 视觉图与主要界面。',
			title: 'Hero 与界面展示'
		},
		hero: {
			badge: 'GitHub Releases ZIP Updater',
			chips: ['专注 ZIP 分发', '英文 / 日文 / 中文', '不收集遥测'],
			ctaPrimary: '查看 GitHub 仓库',
			ctaSecondary: '查看隐私政策',
			description: '只需登记仓库 URL 与 ZIP 匹配规则，即可用统一流程持续更新你的桌面应用。',
			title: '把 ZIP 分发应用的更新管理集中到一个面板。'
		},
		language: {
			label: '界面语言',
			options: {
				auto: '自动',
				ja: '日文',
				en: '英文',
				zh: '中文'
			}
		},
		metrics: [
			{
				value: 'ZIP 优先',
				label: '面向 GitHub Releases ZIP 资产设计'
			},
			{
				value: '3 种语言',
				label: '与应用一致支持英/日/中界面'
			},
			{
				value: '0 追踪',
				label: '应用不进行行为分析与使用追踪'
			}
		],
		nav: {
			github: 'GitHub',
			privacy: '隐私',
			top: '首页'
		},
		privacy: {
			bullets: [
				'已登记仓库信息、安装目录、语言偏好及可选 GitHub Token 仅存储在你的设备本地。',
				'仅当你主动执行检查更新、安装或升级时，应用才会访问 GitHub API 与资源下载地址。',
				'应用不接入分析统计、广告追踪，也不会向外部数据方出售数据。'
			],
			effectiveDate: '生效日期: 2026年2月20日',
			lead: 'zup 是本地运行的桌面应用，不会向开发者发送使用遥测数据。',
			repoCta: '项目仓库与源代码',
			title: '隐私政策'
		},
		seo: {
			homeDescription:
				'zup 是面向 GitHub Releases ZIP 资源的本地运行桌面更新工具，提供英文、日文、中文界面。',
			homeTitle: 'zup | 桌面 ZIP 更新工具',
			privacyDescription: 'zup 桌面更新工具的应用隐私政策。',
			privacyTitle: '隐私政策 | zup'
		}
	}
};

function detectPreferredLocale(languages: readonly string[] | undefined): SupportedLocale {
	for (const language of languages ?? []) {
		const normalized = language.toLowerCase();
		if (normalized.startsWith('ja')) {
			return 'ja';
		}
		if (normalized.startsWith('zh')) {
			return 'zh';
		}
		if (normalized.startsWith('en')) {
			return 'en';
		}
	}
	return fallbackLocale;
}

export function normalizeLocalePreference(
	value: string | null | undefined
): LocalePreference | null {
	if (value == null) {
		return null;
	}

	switch (value.trim().toLowerCase()) {
		case 'auto':
		case 'ja':
		case 'en':
		case 'zh':
			return value.trim().toLowerCase() as LocalePreference;
		default:
			return null;
	}
}

export const localePreference = writable<LocalePreference>('auto');
const autoLocale = writable<SupportedLocale>(fallbackLocale);

export const activeLocale = derived(
	[localePreference, autoLocale],
	([$localePreference, $autoLocale]): SupportedLocale =>
		$localePreference === 'auto' ? $autoLocale : $localePreference
);

export const copy = derived(activeLocale, ($activeLocale) => translations[$activeLocale]);

export function initializeLocalePreference(searchParams: URLSearchParams): void {
	if (browser) {
		autoLocale.set(detectPreferredLocale(navigator.languages));
	}

	const queryPreference = normalizeLocalePreference(searchParams.get('lang'));
	if (queryPreference != null) {
		setLocalePreference(queryPreference);
		return;
	}

	if (!browser) {
		return;
	}

	const storedPreference = normalizeLocalePreference(localStorage.getItem(storageKey));
	if (storedPreference != null) {
		localePreference.set(storedPreference);
	}
}

export function setLocalePreference(preference: LocalePreference): void {
	if (browser && preference === 'auto') {
		autoLocale.set(detectPreferredLocale(navigator.languages));
	}
	localePreference.set(preference);
	if (browser) {
		localStorage.setItem(storageKey, preference);
	}
}

export function localizedHref(
	pathname: string,
	preference: LocalePreference = get(localePreference)
): string {
	if (preference === 'auto') {
		return pathname;
	}

	const url = new URL(pathname, 'https://zup.local');
	url.searchParams.set('lang', preference);
	const search = url.searchParams.toString();
	return search.length === 0 ? url.pathname : `${url.pathname}?${search}`;
}
