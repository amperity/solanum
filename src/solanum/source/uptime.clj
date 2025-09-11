(ns solanum.source.uptime
  "Metrics source that measures the uptime of a host."
  (:require
    [clojure.java.shell :as shell]
    [clojure.string :as str]
    [clojure.tools.logging :as log]
    [solanum.source.core :as source]
    [solanum.system.linux :as linux]))


;; ## Measurements

(source/defsupport :uptime
  #{:linux :darwin})


(defn- measure-linux-uptime
  "Measure the number of seconds the Linux system has been running."
  []
  (let [uptime (linux/read-proc-file "/proc/uptime")]
    (Double/parseDouble (first (str/split uptime #" +")))))


(defn- measure-darwin-uptime
  "Measure the number of seconds the OS X system has been running."
  []
  (let [result (shell/sh "sysctl" "-n" "kern.boottime")]
    (if (zero? (:exit result))
      (let [[_ boot-timestamp] (->> (:out result)
                                    (re-seq #"sec = (\d+),")
                                    (first))
            current-timestamp (quot (System/currentTimeMillis) 1000)]
        (- current-timestamp (Long/parseLong boot-timestamp)))
      (log/warn "Failed to measure uptime:" (pr-str (:err result))))))


;; ## Uptime Source

(defrecord UptimeSource
  []

  source/Source

  (collect-events
    [this]
    (let [seconds (case (:mode this)
                    :linux (measure-linux-uptime)
                    :darwin (measure-darwin-uptime))]
      [{:service "uptime"
        :metric (double seconds)
        :description (str "Up for " (source/duration-str seconds))}])))


(defmethod source/initialize :uptime
  [_]
  (map->UptimeSource {}))
