/**
 * Small module to enforce function like error handling
 */
export type Result<T, E = string> =
  | { ok: true; value: T }
  | { ok: false; error: E };

export const Ok = <T>(value: T): Result<T, never> => ({ ok: true, value });
export const Err = <E>(error: E): Result<never, E> => ({ ok: false, error });

export function unwrapOrElse<T>(
  result: Result<T>,
  onErr: (error: string) => never,
): T {
  if (result.ok) return result.value;
  return onErr(result.error);
}
