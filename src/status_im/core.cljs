(ns status-im.core
  (:require #_[re-frame.core :as re-frame]
            #_[status-im.utils.error-handler :as error-handler]
            #_[status-im.utils.platform :as platform]
            [status-im.ui.components.react :as react]
            [reagent.core :as reagent]
            #_[status-im.utils.logging.core :as utils.logs]
            #_cljs.core.specs.alpha
            ["react-native" :as react-native]))

(if js/goog.DEBUG
  (.ignoreWarnings (.-YellowBox react-native)
                   #js ["re-frame: overwriting"
                        "Warning: componentWillMount has been renamed, and is not recommended for use. See https://fb.me/react-async-component-lifecycle-hooks for details."
                        "Warning: componentWillUpdate has been renamed, and is not recommended for use. See https://fb.me/react-async-component-lifecycle-hooks for details."])
  (aset js/console "disableYellowBox" true))

(defn app-root []
  [react/view {}
   [react/text "hello"]])

(defn init []
  #_(utils.logs/init-logs)
  #_(error-handler/register-exception-handler!)
  #_(re-frame/dispatch-sync [:init/app-started])
  (enableScreens)
  (.registerComponent react/app-registry "StatusIm" #(reagent/reactify-component app-root))
  (.hide ^js react/splash-screen))
