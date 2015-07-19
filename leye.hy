#!/usr/bin/env hy

(import [math [pi]])
(import [hy.lex [tokenize]])
(import [cairo])


(defn list? [l]
  (isinstance l list))


(defn get-size [tree]
  (if (list? tree)
    (if tree
      (+
         (get-size (car tree))
         (get-size (cdr tree)))
      0)
    1))


(defn draw [tree]
  (setv W 1000)
  (setv H 1000)

  (setv surface
    (cairo.ImageSurface cairo.FORMAT_ARGB32 W H))
  (setv cr (cairo.Context surface))

  (let [[sz (get-size tree)]
        [sz/2 (/ sz 2)]
        [ratio (/ (min W H) sz)]]
    (.scale cr
            ratio ratio)
    (.translate cr
                sz/2 sz/2))
  (.scale cr 0.5 0.5)
  (.set_line_width cr 1)


  (defn draw-circle [r]
    (.arc cr 0 0 r 0 (* 2 pi))
    (.stroke cr))


  (defn draw-atom [atom])


  (defn draw-cell [cell]
    (.set-source-rgb cr 0 0 0)
    (draw-circle (get-size cell))

    (if (list? (car cell))
      (draw-cell (car cell))
      (draw-atom (car cell)))

    (when (cdr cell)
      (draw-cell (cdr cell))))

  (draw-cell tree)

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
