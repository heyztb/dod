export const load = async ({ locals }) => {
	return {
		user: locals.user,
		requestId: locals.requestId
	};
};
