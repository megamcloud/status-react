(ns status-im.core
  (:require [re-frame.core :as re-frame]
            [status-im.utils.error-handler :as error-handler]
            [status-im.utils.platform :as platform]
            [status-im.ui.components.react :as react]
            [reagent.core :as reagent]
            [status-im.utils.logging.core :as utils.logs]
            cljs.core.specs.alpha
            ["react-native" :as react-native]))

(if js/goog.DEBUG
  (.ignoreWarnings (.-YellowBox react-native)
                   #js ["re-frame: overwriting"
                        "Warning: componentWillMount has been renamed, and is not recommended for use. See https://fb.me/react-async-component-lifecycle-hooks for details."
                        "Warning: componentWillUpdate has been renamed, and is not recommended for use. See https://fb.me/react-async-component-lifecycle-hooks for details."])
  (aset js/console "disableYellowBox" true))

(defn init [app-root]
  (utils.logs/init-logs)
  (error-handler/register-exception-handler!)
  (re-frame/dispatch-sync [:init/app-started])
  (.registerComponent react/app-registry "StatusIm" #(reagent/reactify-component app-root)))
