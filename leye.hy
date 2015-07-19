#!/usr/bin/env hy

(import
  [math [pi]]
  [hy.lex [tokenize]]
  [cairo]
  [random [random]])

(def W 1000)
(def H 1000)


(defn list? [l]
  (isinstance l list))


(defn size [tree]
  (if (list? tree)
    (if tree
      (+
         (size (car tree))
         (size (cdr tree)))
      0)
    1))


(defn draw [tree]

  ; cairo boilerplate
  (setv surface
    (cairo.ImageSurface cairo.FORMAT_ARGB32 W H))
  (setv cr (cairo.Context surface))

  (let [[sz    (size tree)]
        [sz/2  (/ sz 2)]
        [ratio (/ (min W H) sz)]]
    (.scale     cr ratio ratio)
    (.translate cr sz/2 sz/2))

  (.scale cr 0.5 0.5)
  (.set_line_width cr 1)
  ; ---

  ; drawing functions (stuff> means draw-stuff)
  (defn color! [r g b a]
    (.set-source-rgba cr r g b a))

  (defn translate! [x]
    (.translate cr x 0))

  (defn circle> [r]
    (.arc cr 0 0 r 0 (* 2 pi))
    (.fill cr)
    (.arc cr 0 0 r 0 (* 2 pi))
    (color! 0 0 0 0.2)
    (.stroke cr))

  (defn atom> [atom]
    (color! 0 0 0 1)
    (circle> 1))

  (defn cell> [cell]
    (setv r (size cell))
    (color! 1 1 1 0.1)
    (circle> r)
    ;(.rotate cr (* 2 pi (random)))
    (.rotate cr (/ (* 2 pi) r))

    (.save cr)
    (translate! (-
                  (size (car cell)) r))
    (.rotate cr (/ pi 2))
    ((if (list? (car cell))
       cell>
       atom>)
         (car cell))
    (.restore cr)
    (.save cr)
    (translate! (- r (size (cdr cell))))
    (when (cdr cell)
      (cell> (cdr cell)))
    (.restore cr)

    )
  ; ---

  ; actual drawing
  (cell> tree)
  ; ---

  (.write-to-png surface "out.png"))


(defmain [&rest args]
  (setv file-name
    (get args (if (cdr args)
                1 0)))
  (setv code
    (with [[f (open file-name)]]
    (.read f)))

  (setv tree
    (tokenize code))

  (draw tree))
