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


(defn draw! [tree]

  (defmacro cairo-draw [w h file-name &rest body]
    `(do
       (setv surface
         (cairo.ImageSurface cairo.FORMAT_ARGB32 ~w ~h))
       (setv cr (cairo.Context surface))

       (let [[sz    (size tree)]
             [sz/2  (/ sz 2)]
             [ratio (/ (min W H) sz)]]
         (.scale     cr ratio ratio)
         (.translate cr sz/2 sz/2))

       (.scale cr 0.5 0.5)
       (.set_line_width cr 1)
       ~@body
       (.write-to-png surface ~file-name)))

  (cairo-draw 1000 1000 "out.png"
              (defn color! [r g b a]
                (.set-source-rgba cr r g b a))

              (defn fill! [r g b a]
                (color! r g b a)
                (.fill cr))

              (defn stroke! [r g b a]
                (color! r g b a)
                (.stroke cr))

              (defn translate! [x]
                (.translate cr x 0))

              (defn circle! [r]
                (.arc cr 0 0 r 0 (* 2 pi))
                (.arc cr 0 0 r 0 (* 2 pi)))

              (defn atom! [atom]
                (circle! 1)
                (fill! 0 0 0 1))

              (defmacro move [dx &rest body]
                `(do
                   (.save cr)
                   (translate! ~dx)
                   ~@body
                   (.restore cr)))

              (defn cell! [cell]
                (setv r (size cell))
                (circle! r)
                (fill! 1 1 1 0.1)
                (circle! r)
                (stroke! 0 0 0 0.2)
                ;(.rotate cr (* 2 pi (random)))
                (.rotate cr (/ (* 2 pi) r))

                ;(.rotate cr (/ pi 2))
                (move (- (size (car cell)) r)
                      ((if (list? (car cell))
                         cell!
                         atom!)
                           (car cell)))

                (move (- r (size (cdr cell)))
                      (when (cdr cell)
                        (cell! (cdr cell)))))

              (cell! tree)))


(defmain [&rest args]
  (setv file-name
    (get args (if (cdr args)
                1 0)))
  (setv code
    (with [[f (open file-name)]]
    (.read f)))

  (setv tree
    (tokenize code))

  (draw! tree))
