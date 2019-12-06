/**
 * react-native-dynamic-bundle
 * @flow
 */

// $FlowExpectedError: library code, so RN is not in node_modules
import { NativeModules } from 'react-native';

const { RNDynamicBundle } = NativeModules;

/**
 * Set the active Javascript bundle to the bundle with the given bundle ID in
 * the registry. This will cause the given bundle to be loaded on the next app
 * startup or invocation of `reloadBundle()`.
 */
export const setActiveBundle = (bundleId: string) => {
  RNDynamicBundle.setActiveBundle(bundleId);
}

/**
 * Register a Javascript bundle in the bundle registry. The path to the bundle
 * should be relative to the documents directory on iOS and to the internal app
 * storage directory on Android, i.e. the directory returned by `getFilesDir()`.
 */
export const registerBundle = (bundleId: string, relativePath: string) => {
  RNDynamicBundle.registerBundle(bundleId, relativePath);
}

/**
 * Unregister a bundle from the bundle registry.
 */
export const unregisterBundle = (bundleId: string) => {
  RNDynamicBundle.unregisterBundle(bundleId);
}

/**
 * Reload the bundle that is used by the app immediately. This can be used to
 * apply a new bundle that was set by `setActiveBundle()` immediately.
 */
export const reloadBundle = () => {
  RNDynamicBundle.reloadBundle();
}

/**
 * Returns a promise that resolves to an object with the contents of the bundle
 * registry, where the keys are the bundle identifiers and values are the
 * bundle locations encoded as a file URL.
 */
export const getBundles = (): Promise<{ [key: string]: string }> => {
  return RNDynamicBundle.getBundles();
}

/**
 * Returns a promise that resolves to the currently active bundle identifier.
 * if the default bundle (i.e. the bundle that was packaged into the native app)
 * is active this method will resolve to `null`.
 */
 export const getActiveBundle = (): Promise<string | undefined> => {
   return RNDynamicBundle.getActiveBundle();
 }
