module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src, title, style)
import Html.Events exposing (onClick)
import List exposing (drop, head)
import Maybe exposing (withDefault)
import String exposing (fromFloat)
import Config.Products exposing (Product)


-- SLIDE‐SPECIFIC MESSAGES

type SlideMsg
    = SelectColor Int
    | ToggleInner


{-|
    view isInner selectedIdx maxSwatches slideIndex product

    - isInner     : Bool, whether to show innerUrl (True) or outerUrl (False)
    - selectedIdx : Int, which color swatch is currently selected
    - maxSwatches : Int, the maximum number of swatches across all slides
    - slideIndex  : Int (unused here)
    - product     : Product record
-}
view : Bool -> Int -> Int -> Int -> Product -> Html SlideMsg
view isInner selectedIdx maxSwatches _ product =
    let
        -- unwrap the set‐image URL
        setUrl : String
        setUrl =
            withDefault "" product.setImageUrl

        -- pick the selected color record
        maybeColor =
            head (drop selectedIdx product.colors)

        -- build the single <img> element
        imageElement : Html SlideMsg
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

        -- 1) real badge spans
        badgeElems : List (Html SlideMsg)
        badgeElems =
            List.concat
                [ if product.isNew then
                      [ span [ class "badge" ] [ text "New" ] ]
                  else
                      []
                , if product.isSet then
                      [ span [ class "badge" ] [ text "Set" ] ]
                  else
                      []
                ]

        -- 2) badge placeholder if none
        placeholderBadges : List (Html SlideMsg)
        placeholderBadges =
            if List.isEmpty badgeElems then
                [ span [ class "badge placeholder" ] [] ]
            else
                []

        -- 3) real swatch circles
        swatchElems : List (Html SlideMsg)
        swatchElems =
            List.indexedMap
                (\i c ->
                    span
                        [ class ("swatch" ++ if i == selectedIdx then " selected" else "")
                        , onClick (SelectColor i)
                        , title c.name
                        , style "background-color" c.name
                        ]
                        []
                )
                product.colors

        -- 4) swatch placeholders
        placeholderCount : Int
        placeholderCount =
            maxSwatches - List.length product.colors

        placeholderSpans : List (Html SlideMsg)
        placeholderSpans =
            List.repeat placeholderCount
                ( span [ class "swatch placeholder" ] [] )
    in
    div [ class "slide" ]
        [ -- IMAGE + (toggle only for non‐sets)
          div [ class "slide-image-wrapper" ]
            ((imageElement
                :: if not product.isSet then
                       [ button [ onClick ToggleInner, class "slide-toggle" ] [ text "⟳" ] ]
                   else
                       []
             )
            )

          -- CONTENT BLOCK
        , div [ class "slide-content" ]
            (  -- badges row
               [ div [ class "slide-badges" ] (badgeElems ++ placeholderBadges) ]

               -- titles & prices row: title, then price, then valued price
             ++ [ div [ class "slide-titles-prices" ]
                    ( [ div [ class "slide-title" ] [ text product.title ]
                      , span [ class "slide-price" ]
                             [ text ("$" ++ fromFloat product.price) ]
                      ]
                      ++ case product.setValue of
                             Just v ->
                                 [ span [ class "slide-price-valued" ]
                                     [ text ("Valued at " ++ fromFloat v ++ "$") ]
                                 ]

                             Nothing ->
                                 []
                    )
                ]

               -- swatches row: real + placeholders
             ++ [ div [ class "color-swatches" ] (swatchElems ++ placeholderSpans) ]

               -- description
             ++ [ div [ class "slide-desc" ] [ text product.description ] ]
            )
        ]
