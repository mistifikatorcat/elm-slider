module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
import List exposing (head)
import Config.Products exposing (Product)


-- MESSAGES

type SlideMsg
    = SelectColor Int
    | ToggleInner


-- VIEW

{-|
  isInner = True  → show the “innerUrl” on the first color
  isInner = False → show the “outerUrl”
-}
view : Bool -> Int -> Product -> Html SlideMsg
view isInner _ product =
    let
        -- unwrap the Maybe URL for “set” products
        setUrl : String
        setUrl =
            withDefault "" product.setImageUrl

        -- if non‐set, get the first color (if any)
        maybeColor =
            head product.colors

        -- exactly one image element
        imageElement =
            if product.isSet then
                if setUrl /= "" then
                    img [ src setUrl, class "slide-image" ] []
                else
                    text "No image!"
            else
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
        [ -- IMAGE + hover‐only toggle button
          div [ class "slide-image-wrapper" ]
            [ imageElement
            , button [ onClick ToggleInner, class "slide-toggle" ]
                     [ text "⟳" ]
            ]

        -- CONTENT BELOW THE IMAGE
        , div [ class "slide-content" ]
            (  (if product.isNew then [ span [ class "badge" ] [ text "New" ] ] else [])
             ++ (if product.isSet then [ span [ class "badge" ] [ text "Set" ] ] else [])
             ++ [ div [ class "slide-title" ] [ text product.title ]
                , div [ class "slide-price" ]
                      [ text ("$" ++ String.fromFloat product.price) ]
                ]
             ++ (if not product.isSet then
                    [ div [ class "color-swatches" ]
                        (List.indexedMap
                            (\i c ->
                                span
                                    [ class ("swatch" ++ if i == 0 then " selected" else "")
                                    , onClick (SelectColor i)
                                    ]
                                    ([ text c.name ]
                                     ++ if c.isNew then
                                            [ span [ class "badge" ] [ text "New" ] ]
                                        else
                                            []
                                    )
                            )
                            product.colors
                        )
                    ]
                else
                    []
                )
             ++ [ div [ class "slide-desc" ] [ text product.description ] ]
            )
        ]
