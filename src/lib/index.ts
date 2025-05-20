// place files you want to import through the `$lib` alias in this folder.
export const getDomainFromUrl = (url: string) => {
	const parsedUrl = new URL(url);
	return parsedUrl.hostname;
};
