(ns status-im.android.core
  (:require [reagent.core :as reagent]
            [re-frame.core :refer [subscribe dispatch dispatch-sync]]
            status-im.utils.db
            status-im.ui.screens.db
            status-im.ui.screens.events
            status-im.subs
            [status-im.ui.screens.views :as views]
            [status-im.ui.components.react :as react]
            [status-im.native-module.core :as status]
            [status-im.core :as core]
            ["react-native-screens" :refer (enableScreens)]
            ["react-native-languages" :default react-native-languages]
            ["react-native-shake" :as react-native-shake]
            [status-im.utils.snoopy :as snoopy]
            [status-im.i18n :as i18n]
            [status-im.ui.screens.routing.core :as routing]))

(defn app-state-change-handler [state]
  (dispatch [:app-state-change state]))

(defn on-languages-change [event]
  (i18n/set-language (.-language event)))

(defn on-shake []
  (dispatch [:shake-event]))

(defn root [props]
  (let [keyboard-height (subscribe [:keyboard-height])]
    (reagent/create-class
     {:component-did-mount
      (fn [this]
        (.addListener react/keyboard
                      "keyboardDidShow"
                      (fn [^js e]
                        (let [h (.. e -endCoordinates -height)]
                          (when-not (= h @keyboard-height)
                            (dispatch [:set :keyboard-height h])
                            (dispatch [:set :keyboard-max-height h])))))
        (.addListener react/keyboard
                      "keyboardDidHide"
                      (fn [_]
                        (when-not (zero? @keyboard-height)
                          (dispatch [:set :keyboard-height 0]))))
        (.hide react/splash-screen)
        (.addEventListener react/app-state "change" app-state-change-handler)
        (.addEventListener react-native-languages "change" on-languages-change)
        (.addEventListener react-native-shake
                           "ShakeEvent"
                           on-shake)
        (dispatch [:set-initial-props (reagent/props this)]))
      :component-will-unmount
      (fn []
        (.removeEventListener react/app-state "change" app-state-change-handler)
        (.removeEventListener react-native-languages "change" on-languages-change))
      :display-name "root"
      :reagent-render views/main})))

(defonce component-to-update (atom nil))

(def updatable-root
  (with-meta root
    {:component-did-mount
     (fn []
       (this-as ^js this
                (reset! component-to-update this)))}))

(defn reload
  {:dev/after-load true}
  []
  (.forceUpdate ^js @component-to-update))

(defn init []
  (status/set-soft-input-mode status/adjust-resize)
  (enableScreens)
  (core/init updatable-root)
  (snoopy/subscribe!))
