export const ssr = true;

export const load = async ({ locals }) => {
	return {
		user: locals.user,
		session: locals.session
	};
};
