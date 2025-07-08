# sv

Everything you need to build a Svelte project, powered by [`sv`](https://github.com/sveltejs/cli).

## Creating a project

If you're seeing this, you've probably already done this step. Congrats!

```bash
# create a new project in the current directory
npx sv create

# create a new project in my-app
npx sv create my-app
```

## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```bash
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```bash
npm run build
```

You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0) - see the [LICENSE](LICENSE) file for details.

### Commercial Licensing

**Commercial licenses are available for organizations that wish to use this software in proprietary applications without the AGPL-3.0 copyleft requirements.**

For commercial licensing inquiries, please contact:

- Email: [hi (at) ztb dot dev]
- Website: [https://ztb.dev]

Commercial licenses include:

- Freedom to use in proprietary software
- No requirement to open source your application
- Priority support and maintenance
- Custom development services available
