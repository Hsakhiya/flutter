// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'common.dart';

void main() {
  group('$PathUrlStrategy', () {
    late TestPlatformLocation location;

    setUp(() {
      location = TestPlatformLocation();
    });

    test('allows null state', () {
      location.baseHref = '/';
      final PathUrlStrategy strategy = PathUrlStrategy(location);
      expect(() => strategy.pushState(null, '', '/'), returnsNormally);
      expect(() => strategy.replaceState(null, '', '/'), returnsNormally);
    });

    test('validates base href', () {
      location.baseHref = '/';
      expect(
        () => PathUrlStrategy(location),
        returnsNormally,
      );

      location.baseHref = '/foo/';
      expect(
        () => PathUrlStrategy(location),
        returnsNormally,
      );

      location.baseHref = '';
      expect(
        () => PathUrlStrategy(location),
        throwsException,
      );

      location.baseHref = 'foo';
      expect(
        () => PathUrlStrategy(location),
        throwsException,
      );

      location.baseHref = '/foo';
      expect(
        () => PathUrlStrategy(location),
        throwsException,
      );
    });

    test('leading slash is always prepended', () {
      location.baseHref = '/';
      final PathUrlStrategy strategy = PathUrlStrategy(location);

      location.pathname = '';
      expect(strategy.getPath(), '/');

      location.pathname = 'foo';
      expect(strategy.getPath(), '/foo');
    });

    test('gets path correctly in the presence of basePath', () {
      location.baseHref = 'https://example.com/foo/';
      final PathUrlStrategy strategy = PathUrlStrategy(location);

      location.pathname = '/foo/';
      expect(strategy.getPath(), '/');

      location.pathname = '/foo';
      expect(strategy.getPath(), '/');

      location.pathname = '/foo/bar';
      expect(strategy.getPath(), '/bar');
    });

    test('gets path correctly in the presence of query params', () {
      location.baseHref = 'https://example.com/foo/';
      location.pathname = '/foo/bar';
      final PathUrlStrategy strategy = PathUrlStrategy(location);


      location.search = '?q=1';
      expect(strategy.getPath(), '/bar?q=1');

      location.search = '?q=1&t=r';
      expect(strategy.getPath(), '/bar?q=1&t=r');
    });

    test('generates external path correctly in the presence of basePath', () {
      location.baseHref = 'https://example.com/foo/';
      final PathUrlStrategy strategy = PathUrlStrategy(location);

      expect(strategy.prepareExternalUrl(''), '/foo');
      expect(strategy.prepareExternalUrl('/'), '/foo/');
      expect(strategy.prepareExternalUrl('bar'), '/foo/bar');
      expect(strategy.prepareExternalUrl('/bar'), '/foo/bar');
      expect(strategy.prepareExternalUrl('/bar/'), '/foo/bar/');
    });
  });
}
