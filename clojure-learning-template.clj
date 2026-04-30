(ns learning.core
  "A simple learning project for Clojure development in Neovim"
  (:require [clojure.string :as str]))

;; Basic data types and operations
(def greeting "Hello, Clojure!")

(def numbers [1 2 3 4 5])

(def person {:name "Alice" :age 30 :city "Portland"})

;; Functions
(defn add [a b]
  (+ a b))

(defn greet [name]
  (str "Hello, " name "!"))

(defn square [x]
  (* x x))

;; Higher-order functions
(defn apply-to-all [f xs]
  (map f xs))

(defn double-all [xs]
  (map #(* 2 %) xs))

;; Conditionals and pattern matching
(defn classify-number [n]
  (cond
    (< n 0) "negative"
    (zero? n) "zero"
    (pos? n) "positive"))

;; Sequences and collections
(defn sum-of-squares [xs]
  (->> xs
       (map square)
       (reduce +)))

;; Recursion example
(defn factorial [n]
  (if (<= n 1)
    1
    (* n (factorial (dec n)))))

;; Testing functions (run these in REPL: <space><space>ee)
(comment
  ;; Evaluate these lines one by one with <space><space>ee
  
  ;; Basic operations
  (add 2 3)
  (greet "World")
  (square 5)
  
  ;; Working with sequences
  (map square numbers)
  (filter even? numbers)
  (reduce + numbers)
  
  ;; Working with maps
  person
  (:name person)
  (assoc person :age 31)
  
  ;; Using helper functions
  (double-all [1 2 3 4 5])
  (classify-number -5)
  (classify-number 0)
  (classify-number 10)
  
  ;; Recursion
  (factorial 5)
  
  ;; List comprehension
  (for [x [1 2 3] y [10 20]] [x y])
  
  ;; String operations
  (str/upper-case greeting)
  (str/split greeting #", ")
)
