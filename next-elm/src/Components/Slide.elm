module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
import List exposing (head)
import Config.Products exposing (Product)


-- Messages we handle per slide
type SlideMsg
    = SelectColor Int
    | ToggleInner


{-|
   view isInner selectedIdx slideIndex product

   * isInner     : Bool, show innerUrl if True, outerUrl if False
   * selectedIdx : Int, which color swatch index to show
   * slideIndex  : Int, for Html.map context
   * product     : Product record
-}
view : Bool -> Int -> Int -> Product -> Html SlideMsg
view isInner selectedIdx _ product =
    let
        -- unwrap the Maybe String for set-image
        setUrl : String
        setUrl =
            withDefault "" product.setImageUrl

        -- pick the color record at selectedIdx
        maybeColor =
            head (List.drop selectedIdx product.colors)

        -- build exactly one <img> element
        imageElement : Html SlideMsg
        imageElement =
            if product.isSet then
                -- Show the set image always, ignoring swatches
                if setUrl /= "" then
                    img [ src setUrl, class "slide-image" ] []
                else
                    text "No image!"

            else
                -- Non-set: show outer or inner based on isInner
                case maybeColor of
                    Just c ->
                        let
                            urlToShow =
                                if isInner then
                                    c.innerUrl
                                else
                                    c.outerUrl
                        in
                        img [ src urlToShow, class "slide-image" ] []

                    Nothing ->
                        text "No image!"
    in
    div [ class "slide" ]
        [ -- IMAGE + hover-toggle button
          div [ class "slide-image-wrapper" ]
            [ imageElement
            , button [ onClick ToggleInner, class "slide-toggle" ] [ text "⟳" ]
            ]

          -- CONTENT BELOW THE IMAGE
        , div [ class "slide-content" ]
            (  -- Badges row
               (if product.isNew then
                    [ span [ class "badge" ] [ text "New" ] ]
                else
                    [span [ class "badge placeholder" ] []]
               )
             ++ (if product.isSet then
                    [ span [ class "badge" ] [ text "Set" ] ]
                else
                    [span [ class "badge placeholder" ] []]
                )

             -- Title & price
             ++ [ div [ class "slide-title" ] [ text product.title ]
                , div [ class "slide-price" ] [ text ("$" ++ String.fromFloat product.price) ]
                ]

             -- Color swatches (only for non-set)
             ++ (if not product.isSet then
                    [ div [ class "color-swatches" ]
                        (List.indexedMap
                            (\i c ->
                                span
                                    [ class ("swatch" ++ if i == selectedIdx then " selected" else "")
                                    , onClick (SelectColor i)
                                    ]
                                    [ text c.name ]
                            )
                            product.colors
                        )
                    ]
                else
                    []
                )

             -- Description
             ++ [ div [ class "slide-desc" ] [ text product.description ] ]
            )
        ]
