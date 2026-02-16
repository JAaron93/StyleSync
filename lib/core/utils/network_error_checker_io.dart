import 'dart:io';

// Native implementation for platforms where dart:io is available.
//
// Provides type-safe checks for network-related exceptions from dart:io.

/// Returns `true` if [error] is a [SocketException].
bool isSocketException(Object? error) => error is SocketException;

/// Returns `true` if [error] is an [HttpException].
bool isHttpException(Object? error) => error is HttpException;
