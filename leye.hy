#!/usr/bin/env hy

(import
  [math [pi]]
  [hy.lex [tokenize]]
  [cairo]
  [random [random]])


(defn list? [l]
  (isinstance l list))


(defn size [tree]
  (if (list? tree)
    (if tree
      (+
         1
         (size (car tree))
         (size (cdr tree)))
      0)
    1))


(defn draw! [tree]

  (defmacro cairo-draw [w h file-name &rest body]
    `(do
       (setv surface
         (cairo.SVGSurface ~file-name ~w ~h))
       (setv cr (cairo.Context surface))

       (let [[sz    (size tree)]
             [sz/2  (/ sz 2)]
             [ratio (/ (min ~w ~h) sz)]]
         (.scale     cr ratio ratio)
         (.translate cr sz/2 sz/2))

       (.scale cr 0.5 0.5)
       (.set_line_width cr 1)
       ~@body))

  (cairo-draw 1000 1000 "out.svg"
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
                (.arc cr 0 0 r 0 (* 2 pi)))

              (defmacro move [dx &rest body]
                `(do
                   (.save cr)
                   (translate! ~dx)
                   ~@body
                   (.restore cr)))

              (defn cell! [cell]
                (when cell
                  (setv r (size cell))

                  (circle! r)
                  (if (list? (car cell))
                    (do
                      (fill! 1 1 1 0.1)
                      (circle! r)
                      (stroke! 0.5 0.5 0.5 1)

                      (.rotate cr (/ pi 2))
                      (move (- (size (car cell)) r)
                            (cell! (car cell)))
                      (move (- r (size (cdr cell)))
                        (cell! (cdr cell))))

                    (do
                      (stroke! 0 0 1 0.5)
                      (cell! (cdr cell))))))

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
