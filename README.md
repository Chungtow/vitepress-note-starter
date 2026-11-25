<p align="center">
  <img src="./assets/logo.svg" width="120" height="120" alt="vitepress-note-starter logo">
</p>

<h1 align="center">vitepress-note-starter</h1>

<p align="center">
  <b>English</b> ·
  <a href="./README.zh-CN.md">简体中文</a> ·
  <a href="https://chungtow.github.io/vitepress-note-starter/">Website</a>
</p>

<p align="center">A ready-to-use VitePress starter for personal notes and documentation</p>
<p align="center">Docker and Git are all you need locally; push to <code>main</code> and GitHub Pages takes over</p>

<p align="center">
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-blue.svg" alt="License"></a>
  <a href="https://vitepress.dev"><img src="https://img.shields.io/badge/VitePress-1.6.4-42b883?logo=vite&logoColor=white" alt="VitePress"></a>
  <img src="https://img.shields.io/badge/node-%E2%89%A5_20-339933?logo=node.js&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/pnpm-10.34.9-F69220?logo=pnpm&logoColor=white" alt="pnpm">
  <img src="https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white" alt="Docker">
  <a href="https://github.com/Chungtow/vitepress-note-starter/actions/workflows/deploy.yml"><img src="https://github.com/Chungtow/vitepress-note-starter/actions/workflows/deploy.yml/badge.svg" alt="Deploy status"></a>
</p>

## Overview

This repository is a VitePress starter that can be put to work immediately. It is meant for people who plan to maintain personal notes or team documentation over a long period and would rather not keep reconfiguring a toolchain.

The repository contains only the framework and sample content, with no private data. After cloning, edit a few fields in `content/.vitepress/site.ts` and the `content/` directory becomes your notebook. Adding pages, adjusting navigation and changing the theme color do not require touching the build configuration.

Publishing defaults to GitHub Pages: once you push to `main`, GitHub Actions builds the site and deploys it. If your code lives on Alibaba Cloud Codeup, GitLab or an internal server, the included initialization script generates a project with no dependency on GitHub, along with Docker and nginx deployment options.

## Features

- **One configuration file.** The site title, description, `base` path, navigation, sidebar and footer all live in `content/.vitepress/site.ts`, annotated in Chinese.
- **No local Node installation.** Node 22 and pnpm run inside a Docker container. The image ships the runtime only, not VitePress itself; the site source is mounted as a volume, so edits inside the container are edits on the host and hot reload works normally.
- **Push to deploy.** `.github/workflows/deploy.yml` is built on the official GitHub Pages actions (`configure-pages@v5`, `upload-pages-artifact@v3`, `deploy-pages@v4`). No pipeline changes are needed when you use the template.
- **A complete writing experience.** Local search is enabled and adapted for Chinese text, together with Mermaid diagrams, code block line numbers, dark mode and the usual Markdown extensions.
- **A path to private environments.** `scripts/init-private-site.sh` produces a new project without GitHub dependencies: it strips `.github/`, fills in the site configuration and adds nginx and Docker deployment files for Codeup, GitLab or internal servers.
- **Clear separation of concerns.** `content/` holds your material and can be edited freely; `docker/` and `.github/` are framework files that normally need no attention.

## Project structure

```text
vitepress-note-starter/
├── .agents/
│   └── skills/
│       └── vitepress-doc-import/   # agent skill for importing existing Markdown, see "Adding documents"
├── .github/
│   └── workflows/
│       └── deploy.yml           # push to main, then build and publish to GitHub Pages
├── docker/                      # all container-related files live here
│   ├── Dockerfile               # node:22 with pnpm, no site source
│   ├── docker-compose.yml       # mounts the repository root at /app
│   └── .env.example             # copy to .env to set port, image name, npm registry
├── content/                     # all notes go here
│   ├── .vitepress/
│   │   ├── site.ts              # the only file you need to edit (title, base, nav, sidebar, footer)
│   │   ├── config.mts           # framework config: search, Mermaid, Chinese UI text
│   │   ├── search-tokenize.ts   # Chinese search tokenizer
│   │   └── theme/index.ts       # custom theme entry, extends the default theme
│   ├── public/                  # static assets (site logo, images, CNAME)
│   ├── index.md                 # home page
│   ├── guide/                   # usage guide, safe to delete
│   │   ├── index.md
│   │   ├── markdown.md
│   │   ├── mermaid.md
│   │   ├── deploy.md            # deployment model, base path, custom domains
│   │   └── github-setup.md      # one-time GitHub setup, where to find the Pages URL
│   └── notes/                   # notes section, sample content can be edited or removed
│       ├── index.md
│       └── demo.md
├── scripts/
│   └── init-private-site.sh     # generate a private project: drop GitHub, add deploy files
├── .dockerignore
├── .gitignore
├── package.json                 # dev, build and preview scripts
├── pnpm-lock.yaml
├── LICENSE
├── README.md                    # this file
└── README.zh-CN.md              # Chinese documentation
```

## Getting started

Four workflows are covered below. First, a note on placeholders: anything wrapped in angle brackets must be replaced with your own value, and the brackets themselves are not part of the command.

| Placeholder | Meaning | Example |
| --- | --- | --- |
| `<dir>` | local project directory, may include a path | `notes`, `~/work/notes` |
| `<repo>` | name of the repository you create | `notes` |
| `<group>` | Codeup or GitLab group / namespace | `mygroup` |
| `<site-name>` | site title, shown in the browser tab and page header | `Team docs` |
| `<sub-path>` | sub-path the site is mounted on | `notes` |
| `<description>` | short site description | `Internal documentation` |
| `<username>` | your GitHub username | `octocat` |
| `<server>` | server hostname or internal IP | `10.0.0.12` |
| `<server-user>` | account used to log in to the server | `root` |
| `<branch>` | git branch name | `main` |

Names such as `my-notes` and `notes.example.com` that appear in the examples are placeholders as well; substitute your own.

### Option 1: Use this template (recommended, public repository with GitHub Pages)

The template button sits above the file list on the repository home page, next to the `<> Code` button, and is labeled **Use this template**. It is not in the Watch, Fork and Star row in the upper right; Fork lives there. You can also open `https://github.com/<username>/<repo>/generate` directly.

If the button is missing, the template feature has not been enabled for the repository. The repository owner needs to tick **Settings → General → Template repository** once.

#### Step 1: create the repository and clone it

1. Click **Use this template → Create a new repository**.
2. Choose a repository name such as `my-notes`. This name determines the value of `base` later, so avoid changing it once created.
3. Clone the repository locally, replacing `<username>` with your GitHub username:

```bash
git clone git@github.com:<username>/my-notes.git    # replace my-notes with your repository name
cd my-notes
```

#### Step 2: configure the site

Only `content/.vitepress/site.ts` needs editing:

```ts
export const site = {
  base: '/my-notes/',                    // must equal the repository name, with both slashes
                                         // use '/' when the repository is <username>.github.io
  title: 'My Notes',                     // site name in the browser tab and page header
  titleTemplate: ':title | My Notes',     // keep this in sync with the title above
  description: 'My personal notes',       // one-line description
  nav: [ /* top navigation, add or remove entries */ ],
  sidebar: { /* left sidebar, grouped by directory */ },
  socialLinks: [ /* icons in the upper right, use [] to hide */ ],
  footer: { /* page footer, delete the block to omit it */ }
}
```

`base` must match the path portion of `https://<username>.github.io/`. When it is wrong, the site usually loads without any styling, leaving plain unstyled HTML on a white background.

#### Step 3: preview locally

Docker is the only local requirement:

```bash
cd docker
cp .env.example .env        # optional: needed only to change port or image name, default is 5173
docker compose up -d --build   # first run builds the image and installs dependencies, about 1-3 minutes
docker compose logs -f         # wait for Local: http://localhost:5173/my-notes/
```

Opening `http://localhost:5173/` redirects with a 302 to the path specified by `base`, for example `/my-notes/`. This is expected behavior, not a misconfiguration.

Stop the container with `docker compose down`. Later edits to documents or components need no extra steps, because hot reload applies them immediately. Changes to `package.json` dependencies require `docker compose restart site` so that dependencies are reinstalled; `--build` does not cover that case, as explained under Local development.

#### Step 4: push and wait for the deployment

```bash
git add .
git commit -m "docs: first note"
git push origin main
```

#### Step 5: one-time settings on GitHub

Three settings are needed before the first deployment:

1. **Settings → Pages → Build and deployment → Source**: select **GitHub Actions**, not Deploy from a branch.
2. **Settings → General → Default branch**: confirm it is **main**.
3. If the repository was forked, open **Actions** and click *"I understand my workflows, go ahead and enable them"*.

#### Step 6: verify

```bash
# Deploy VitePress to GitHub Pages turns green in the Actions tab, usually within a minute
curl -I https://<username>.github.io/<repo>/    # replace with your URL, expect 200
```

If styling is missing, `base` is incorrect. Fix it and push again to trigger a new build.

### Option 2: Fork (keep the link to this template)

If you want a clean copy while keeping your notes private, create a **Private** repository with Option 1 instead. Fork only works on public repositories, and on the free plan Pages requires a public repository as well.

#### Step 1: fork and enable Actions

1. Click **Fork** in the upper right of the repository page. This is Fork, not Use this template.
2. Open the forked repository, switch to the **Actions** tab and click *"I understand my workflows, go ahead and enable them"*. Without this step the workflow never runs, and later pushes deploy nothing.

#### Step 2: configure Pages

Go to **Settings → Pages → Build and deployment → Source** and select **GitHub Actions**. Forked repositories do not inherit this setting.

#### Step 3: clone and update base

```bash
# replace <username> with your GitHub username
git clone git@github.com:<username>/vitepress-note-starter.git
cd vitepress-note-starter
```

Edit `content/.vitepress/site.ts` following the same rules as Option 1, Step 2:

```ts
base: '/vitepress-note-starter/',   // equals the forked repository name; use '/' for <username>.github.io
```

#### Step 4: preview locally

```bash
cd docker
cp .env.example .env        # optional: needed only to change port or image name, default is 5173
docker compose up -d --build
docker compose logs -f         # wait for Local: http://localhost:5173/vitepress-note-starter/
```

#### Step 5: push and verify

```bash
git add .
git commit -m "docs: first note"
git push origin main
curl -I https://<username>.github.io/vitepress-note-starter/    # replace with your URL, expect 200
```

Forking has one long-term cost: **Sync fork** can pull template updates, but those updates arrive in your repository as well, and your own `site.ts` and documents may need conflicts resolved. When you only need a clean copy, Option 1 is less work.

### Option 3: private projects (Codeup, GitLab, internal servers)

This option targets repositories hosted on Alibaba Cloud Codeup, GitLab or a self-hosted Gitea, with the site deployed on your own server. Docker is the default: the build and the web server both run in containers, so a single command brings the site up. If nginx is already running on the server, the built output can be published as static files instead, as described in Step 6B. GitHub is not involved at any point.

The initialization script copies the template (excluding `.git`, `node_modules` and build output), removes `.github/` and the sample pages about Pages, generates `content/.vitepress/site.ts`, creates a blank document skeleton (home page, overview, writing conventions) and a trimmed `README.md`, generates deployment files according to `--deploy`, and finally runs `git init -b main` with `origin` pointing at your private repository.

#### Prerequisites

| Check | How to confirm |
| --- | --- |
| The private repository exists and is empty | Do not initialize it with a README or .gitignore; existing content makes later pushes fail |
| Your SSH key is registered with Codeup | `ssh -T git@codeup.aliyun.com` returns login information |
| Docker is available locally (or Node 22 with pnpm) | `docker version` or `node -v` |

#### Step 1: clone the template into the target directory

```bash
# replace <dir> with your project path, for example ~/work/notes; it must not exist or must be empty
mkdir -p <dir> && cd <dir>
git clone git@github.com:Chungtow/vitepress-note-starter.git .
```

#### Step 2: run the conversion command

Replace each value with your own:

```bash
bash scripts/init-private-site.sh --in-place \
  --name "<site-name>" \
  --desc "<description>" \
  --base / \
  --deploy docker \
  --repo git@codeup.aliyun.com:<group>/<repo>.git
```

| Flag | What to provide |
| --- | --- |
| `--name` | Site title, shown in the browser tab and page header |
| `--desc` | One-line description |
| `--base` | Access path. Use `/` when the site sits at the root of a domain or port (`http://notes.example.com/`, `http://10.0.0.12:8080/`), or `/<sub-path>/` when it is mounted under an existing site |
| `--deploy` | `docker` (recommended, Step 6A), `nginx` (publish static files through an existing nginx, Step 6B), or `none` (generate the site only and copy `dist` yourself) |
| `--repo` | SSH URL of your private repository, copied from the clone dialog on Codeup |
| `--reset-git` | Optional. Drops the template history and removes the link to GitHub; omit it to keep the history and pull template updates later with `git pull` |
| `--web-root` | Only used with `--deploy nginx`, and can be supplied later: the directory on the server that receives each release (for example `/data/www/notes`). It must match `root` in `deploy/nginx.conf` |

Do not append `#` comments to the end of these multi-line commands; the comment breaks the line continuation and the command fails. Add `--keep-samples` to keep the Markdown and Mermaid samples, or `--keep-github` to stay on GitHub Pages. Run `bash scripts/init-private-site.sh --help` for the full list of flags.

#### Step 3: check the result

Run the following commands and confirm each output before continuing:

```bash
git remote -v      # only the codeup entry; any github entry means the cleanup is incomplete
ls scripts deploy  # init-private-site.sh present; deploy/ contains Dockerfile, nginx.conf, docker-compose.yml
grep -E "base|title" content/.vitepress/site.ts        # base and title show the values you provided
grep -rn "github" --include="*.ts" --include="*.md" . | grep -v node_modules   # expect no output
```

#### Step 4: preview locally

```bash
# optional: copy the configuration template; skip it when port and image name are unchanged
cd docker
cp .env.example .env

docker compose up -d --build
docker compose logs -f    # wait for Local: http://localhost:5173...
```

`docker/.env` is a local file listed in `.gitignore`, so a freshly cloned or generated directory never contains one. The stack starts without it and simply uses the default port `5173`. Copy and edit it when you need a different port or want to run several sites on the same machine by changing `IMAGE_NAME` and `CONTAINER_NAME`.

#### Step 5: first commit and push

```bash
git add -A
git commit -m "chore: initialize the documentation site"
git push -u origin main      # -u is required the first time, after that plain git push works
```

A push rejected with `[rejected] non-fast-forward` means the Codeup repository already has content, usually because it was created with a README. Empty it and push again; if you are certain nothing in it matters, `git push -u origin main --force` also works.

#### Step 6A: deploy with Docker (recommended)

The project already contains `deploy/Dockerfile` and `deploy/docker-compose.yml`. The Dockerfile is a multi-stage build: it runs `pnpm build` in a Node image and then serves the static output with nginx. Copy the project to the server and start it with one command:

```bash
cd <dir>                                              # the project directory on the server
docker compose -f deploy/docker-compose.yml up -d --build

docker compose -f deploy/docker-compose.yml ps        # status
docker compose -f deploy/docker-compose.yml logs -f   # logs
```

The site is published on host port `8080` and reachable at `http://<server>:8080`. To change the port, edit `"8080:80"` in `deploy/docker-compose.yml`.

To publish documentation updates later, run `git pull` on the server and repeat the same `up -d --build` command. The image is rebuilt, and nothing needs to be installed on the host.

You can also run `docker build -f deploy/Dockerfile -t <image>:<tag> .` on a build machine or in a pipeline, push the image to a private registry, and run `docker pull` followed by a restart on the server. This suits setups where the build host and the runtime host are separate.

#### Step 6B: deploy with nginx (optional)

Use this only when nginx already runs on the server and you would rather not run another container. Step 2 needs `--deploy nginx --web-root <server-dir>`, or you can add it later by rerunning the script with `--in-place` from the project root.

1. Edit two lines in `deploy/nginx.conf`:

```nginx
server {
    listen 80;
    server_name notes.example.com;      # your domain or internal IP
    root /data/www/<dir>;               # must match --web-root
    ...
}
```

2. Copy it to the server and reload, replacing `<server-user>` and `<server>` with real values:

```bash
scp deploy/nginx.conf <server-user>@<server>:/tmp/site.conf
ssh <server-user>@<server> 'sudo mv /tmp/site.conf /etc/nginx/conf.d/site.conf && sudo nginx -t && sudo nginx -s reload'
```

3. Publish each release with one command that builds and syncs:

```bash
bash scripts/deploy.sh      # pnpm install --frozen-lockfile && pnpm build && rsync to WEB_ROOT
```

To override the destination temporarily, run `WEB_ROOT=/srv/www/<dir> bash scripts/deploy.sh`. The server needs `rsync`; install it with `sudo apt install -y rsync`, or use the Docker approach from Step 6A instead.

#### Step 7: verify

```bash
# option A (Docker, port 8080 by default)
curl -I http://<server>:8080/                            # expect 200
curl -s http://<server>:8080/ | grep -c 'assets/app'     # expect 1, which proves assets are referenced

# option B (nginx)
curl -I http://notes.example.com/                        # replace with your URL, expect 200
```

#### Appendix: generate outside the current directory

Use `--dir` to create the project at a given path while keeping the template directory untouched. Run this from the template directory:

```bash
bash scripts/init-private-site.sh --dir ../<dir> \
  --name "<site-name>" --base / --deploy docker \
  --repo git@codeup.aliyun.com:<group>/<repo>.git
```

#### Appendix: troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| Pages load without styling (plain HTML) | `base` does not match the actual URL. Edit `base` in `site.ts` and rebuild or redeploy |
| `bash: scripts/init-private-site.sh: No such file` | The template checkout is older than the script. Run `git pull` in the template directory first |
| Push rejected with `[rejected]` | The Codeup repository is not empty. Empty it and push again, or use `--force` if nothing in it matters |
| `rsync: command not found` | Install rsync on the server, or switch to `--deploy docker` |
| Template updates can no longer be synced | `--reset-git` drops the history. Keep it instead with `git remote rename origin upstream` |
| `--deploy` was forgotten | Rerun the script with the flag. It regenerates `site.ts` and the document skeleton, so back up your own content first |

### Option 4: scaffolding only, detached from any repository

Use this when the site should come up first and hosting can be decided later, or when the project never enters version control at all. The result has no remote, no commit history and no `.github/`, while `site.ts`, the document skeleton and the deployment scripts are all in place.

#### Step 1, approach A (recommended): clone in place and convert

```bash
# replace <dir> with your project path, for example ~/work/notes; it must not exist or must be empty
mkdir -p <dir> && cd <dir>
git clone git@github.com:Chungtow/vitepress-note-starter.git .

bash scripts/init-private-site.sh --in-place \
  --name "<site-name>" \
  --base / \
  --reset-git            # key flag: without it, origin still points at GitHub
```

A single clone and one command finish the job with the fewest steps. `--reset-git` deletes `.git` and reruns `git init -b main`, so the GitHub remote and the commit history disappear while the working tree stays intact, including `scripts/`, `site.ts` and the document skeleton.

#### Step 1, approach B: generate from outside with --dir

If even a short-lived `.git` is undesirable, for example because the target directory will later be merged into another repository, generate the project from outside:

```bash
# 1) clone the template to a temporary directory only to obtain the script
git clone --depth 1 git@github.com:Chungtow/vitepress-note-starter.git /tmp/tpl
cd /tmp/tpl

# 2) generate the scaffold; omitting --repo means no remote is configured at all
#    --dir    target path, created when missing; the example places it next to the temporary template
#    --name   site title
#    --base   deployment path: / for a domain root, /<sub-path>/ for a sub-path
#    --deploy optional: docker or nginx; omit it to generate the site only
bash scripts/init-private-site.sh --dir ../<dir> \
  --name "<site-name>" \
  --base /

# 3) remove the temporary template and enter the generated project
rm -rf /tmp/tpl
cd ../<dir>
```

This takes two more steps than approach A and keeps the template and the output fully separate: the template exists only under `/tmp/tpl` and is deleted afterwards, while the new project holds nothing but a fresh `git init` repository with the files already staged, no remote and no commits.

#### Step 2: confirm the result is clean

```bash
git remote -v                          # expect: no output
git log --oneline 2>/dev/null          # expect: fatal ... does not have any commits yet
ls -d .github 2>/dev/null || echo "no .github"    # expect: no .github
grep -E "base|title" content/.vitepress/site.ts   # expect: the values you provided
```

#### Step 3: start local development

```bash
# optional: copy the configuration template; skip it when port and image name are unchanged
cd docker
cp .env.example .env

docker compose up -d --build
docker compose logs -f    # wait for Local: http://localhost:5173/
```

`docker/.env` is not committed, so a new directory never contains it. The stack starts without it, using port `5173`.

#### Connecting a repository or deploying later

```bash
# connect a repository; Codeup, GitLab and self-hosted servers all work
# example: git@codeup.aliyun.com:<group>/<repo>.git
git remote add origin <repository-url>
git add -A
git commit -m "chore: initialize the documentation site"
git push -u origin main

# add deployment files by rerunning the script with --in-place from the project root
# note: this regenerates site.ts and the document skeleton, so commit or back up your content first
bash scripts/init-private-site.sh --in-place --name "<site-name>" \
  --base / --deploy nginx --web-root /data/www/<dir>
```

#### Appendix: troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| `git remote -v` still shows a GitHub URL | `--reset-git` was omitted. Rerun with it, or run `git remote remove origin` manually |
| `git log` shows template commits | The history was not reset; only `--reset-git` rebuilds `.git` |
| Sample documents are wanted for reference | Add `--keep-samples` to keep the Markdown and Mermaid samples |
| The script should not create a `main` branch | Nothing to do; use `git branch -m <branch>` if you prefer another name |

## Local development

### Docker (recommended; Docker is the only requirement)

Run these from the repository root:

| Task | Command |
| --- | --- |
| Prepare configuration (optional, skip when the port is fine) | `cd docker && cp .env.example .env` |
| Start (builds the image and installs dependencies on first run, **passes --build by default**) | `cd docker && docker compose up -d --build` |
| Start without checking the image (safe when image sources are untouched) | `cd docker && docker compose up -d` |
| Reinstall dependencies after editing `package.json` or `pnpm-lock.yaml` | `cd docker && docker compose restart site` |
| Follow logs | `docker compose logs -f` |
| Run a command inside the container | `docker compose exec site sh` |
| Stop the container | `docker compose down` |
| Stop and wipe the dependency volume | `docker compose down -v` |
| Produce a build | `docker compose run --rm site sh -c "pnpm install && pnpm build"` |

`docker/.env` is not committed, so a fresh clone contains only `.env.example`. The stack still starts without it, because `DEV_PORT`, `IMAGE_NAME`, `CONTAINER_NAME`, `PNPM_VERSION` and `NPM_REGISTRY` all define defaults through `${VAR:-default}` in `docker-compose.yml`, which means port 5173.

#### Why the start command always includes --build

`docker compose up -d` builds an image only when none exists locally. Once the image is present, editing `docker/Dockerfile` or changing `PNPM_VERSION` and `NPM_REGISTRY` in `docker/.env` produces nothing but a `Container ... Running` line, and the container keeps running the old image. Passing `--build` includes the image definition in that comparison and closes the gap.

The cost is negligible in the steady state: a no-op build takes about a second, every layer reports a cache hit, the image ID stays the same and the container is not recreated. The only noticeable expense appears when the base image `node:22-bookworm-slim` is updated upstream: a full rebuild follows, roughly 25 seconds including `apt-get` and `npm install`, and the container is recreated so the dev server restarts. That rebuild is the desired behavior, not a side effect.

Three cases do not need `--build`:

- `DEV_PORT` or `CONTAINER_NAME` changed; both act on the container layer, and `up -d` recreates the container without touching the image;
- `IMAGE_NAME` changed; the new name has no local image yet, so `up -d` builds automatically;
- the image definition is known to be untouched and you want to save that second.

Two kinds of changes are outside the reach of `--build`, because dependencies do not live in the image and the source is mounted as a volume. Editing documents, components or `content/.vitepress/site.ts` needs no action at all, since hot reload applies the change. Editing `package.json` or `pnpm-lock.yaml` requires `docker compose restart site` so that the `pnpm install` in `command` runs again.

### Host machine (optional; requires Node 20 or newer and pnpm)

```bash
pnpm install
pnpm dev       # development: http://localhost:5173/
pnpm build     # build: content/.vitepress/dist/
pnpm preview   # preview the build: http://localhost:4173/
```

`--host 0.0.0.0` is already part of the `package.json` scripts, so the site is reachable from outside the container.

## Adding documents

Pages under `content/` can of course be written by hand: create a `.md` file and add one line to the `sidebar` in `content/.vitepress/site.ts`. But importing an existing batch of Markdown (dozens of files, relative links, `{{ }}` expressions and `ARRAY<STRING>`-style text) means rewriting links file by file and chasing build errors, so the repository ships an agent skill for that job:

```text
.agents/skills/vitepress-doc-import/
├── SKILL.md                           # workflow, grouping and slug rules, acceptance checklist
├── references/vitepress-pitfalls.md   # pitfalls and internals: Vue compile errors, search index, hot reload
└── scripts/
    ├── import_docs.py                 # batch import: copy, rewrite links, Vue-safe syntax, per-file checks
    └── check_site.py                  # site check: pages and build output, sidebar links, dead links
```

Open this repository in a coding assistant that supports agent skills (Claude Code, CodeBuddy and similar) and say "import the docs under `<src-dir>` into the documentation site as group `<group>`"; the assistant reads `SKILL.md` and follows the workflow. Without an assistant, run the scripts manually as described below. All commands run from the repository root, and `<group>` is the target directory inside the content root, for example the existing `notes`.

The division of labor is deliberate: **mechanical conversion belongs to the scripts, grouping and naming belong to you**. The script copies files, rewrites links between documents in the same batch, demotes `../xxx.md` links that point outside the batch to plain text, turns `{{ … }}` and bare generics into Vue-safe syntax, and checks every file. It does not decide how many groups to create, what a URL should look like, or what the menu label should say.

### Step 1: survey the source directory

```bash
find <src-dir> -type f -name '*.md' | sort
for f in <src-dir>/*.md; do printf '%-46s | ' "$(basename "$f")"; grep -m1 '^# ' "$f" || echo '!! no H1'; done
grep -rnE '!\[[^]]*\]\(' <src-dir>/*.md | head        # images are not moved automatically
grep -rnE '\]\((\.\./|\./)' <src-dir>/*.md | head     # relative links are rewritten or demoted
```

Three things are worth recording: the page count, whether every file has an H1 (add a frontmatter `title` when it does not), and whether images or relative links exist. Images must be copied into `content/public/` yourself, with references rewritten to something like `/img/x.png`.

### Step 2: design groups and slugs

- Group by reader flow, not by original directory names: ask which page a newcomer enters through and which pages they read next, then sort accordingly.
- Keep the navigation to 5-8 groups with 2-7 pages each, and allow at most one or two single-page groups.
- File names are always ascii kebab-case: `快速上手-操作指南.md` becomes `getting-started/quickstart.md`. Chinese characters and spaces turn into `%E4%B8%AD` and `%20` in URLs.
- Use the original H1 as the page title, not the file name.

### Step 3: write the map and dry-run it

The map is a JSON object: keys are source file names, values are **paths relative to `--group`** (no group prefix).

```bash
cat > /tmp/doc-import-map.json <<'JSON'
{
  "快速上手-操作指南.md": "getting-started/quickstart.md",
  "常见问题排查.md":      "troubleshooting/faq.md"
}
JSON

python3 .agents/skills/vitepress-doc-import/scripts/import_docs.py \
  --src <src-dir> --site-content ./content --group <group> \
  --map /tmp/doc-import-map.json --dry-run
```

`--dry-run` prints per-file conversion counts (`vpr` interpolations, `gen` generics, `tag` tags, `rlk` rewritten links, `dmt` demoted links) plus a warning for missing H1s, exits non-zero when it finds something that would break the build, and writes nothing.

You can also run it without a map first: the script guesses a draft from the ASCII fragments in the file names and prints it (all-Chinese names degrade to `doc.md`, `doc-2.md`). Add `--suggest-out /tmp/map.suggested.json` to save it.

### Step 4: run the import

Rerun the same command without `--dry-run`; files land under `content/<group>/...` with links rewritten and syntax made Vue-safe.

### Step 5: add an overview page and navigation

The script never touches site configuration, so three things remain:

1. Write `content/<group>/index.md`: a "what I want to do → which page to read" table, the page count per group, and any reading notes.
2. Add `{ text: '<label>', link: '/<group>/' }` to `nav` in `content/.vitepress/site.ts`, and list every page under `sidebar['/<group>/']`. New pages do not appear in the sidebar on their own.
3. Point the hero button and `features` cards on `content/index.md` at the new group where it makes sense.

### Step 6: build check and search index

```bash
docker compose -f docker/docker-compose.yml exec site sh -c "cd /app && pnpm build"   # expect build complete

python3 .agents/skills/vitepress-doc-import/scripts/check_site.py \
  --site-content ./content --group <group> --site-ts ./content/.vitepress/site.ts

rm -rf content/.vitepress/dist        # build output is only needed during the build; leaving it floods dev logs
```

The local search index is built in full when the dev server starts or restarts, so a new `.md` file does not enter it automatically. Restart the VitePress process once:

```bash
touch content/.vitepress/site.ts
docker compose -f docker/docker-compose.yml logs --tail 10 site | grep 'restarting server'
```

Then reload the browser and search again. `documentCount` accumulates per heading, so it usually runs into the thousands and does not track the page count.

When a build fails with `Error parsing JavaScript expression` or `Element is missing end tag`, read section 1 of `references/vitepress-pitfalls.md` first: the reported line numbers belong to generated code, not to the Markdown file, so hunting by line number wastes time.

## Deployment notes

This section covers Options 1 and 2, which use GitHub Pages. Options 3 and 4 do not involve GitHub: Option 3 uses the generated `deploy/` directory (nginx configuration or Dockerfile) and `scripts/deploy.sh`; Option 4 ships no deployment files by default and can add them following "Connecting a repository or deploying later".

- Trigger: a push to `main`, or a manual `Run workflow` from the Actions tab.
- Permissions: `contents: read`, `pages: write` and `id-token: write`. Missing any of them fails the run; all three are already in the workflow.
- Concurrency: `group: pages` keeps a single deployment running at a time, so runs never overwrite each other.
- Artifact: `content/.vitepress/dist` is uploaded as a Pages artifact and published by `actions/deploy-pages`.
- Site URL: the banner at the top of **Settings → Pages**, the environment link of the deploy job in Actions, or `https://<username>.github.io/<repo>/` directly.
- Custom domain: place a `CNAME` file in `content/public/`, set `base` to `'/'`, and fill in the domain under Settings → Pages.

Three things are needed on the GitHub side, once each: **Settings → Pages with Source set to GitHub Actions**, **`main` as the default branch**, and **Template repository enabled by the template owner**.

Step-by-step instructions, failure causes and where to find the Pages URL are covered in `content/guide/github-setup.md`; the deployment model, `base` path and custom domains are covered in `content/guide/deploy.md`.

## Miscellaneous

- The repository ships the framework and sample content only. The samples under `content/guide/` and `content/notes/` can be deleted entirely and replaced with your own notes.
- The logo at the top of this file is hand-written SVG stored in `assets/logo.svg`. The site logo lives in `content/public/logo.svg`, and the two are interchangeable.
- License: [Apache-2.0](./LICENSE).
