// Stub implementation for web platform where dart:io is unavailable.
//
// On web, SocketException and HttpException from dart:io do not exist,
// so these checks always return false. Network errors on web manifest as
// different types (e.g., XMLHttpRequest errors).

/// Returns `true` if [error] is a `SocketException`.
/// Always returns `false` on web since dart:io types don't exist.
bool isSocketException(Object? error) => false;

/// Returns `true` if [error] is an `HttpException`.
/// Always returns `false` on web since dart:io types don't exist.
bool isHttpException(Object? error) => false;
