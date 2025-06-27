import type { LayoutServerLoadEvent } from './$types';
export async function load({ locals }: LayoutServerLoadEvent) {
    const { user } = locals;
    return { user };
}
