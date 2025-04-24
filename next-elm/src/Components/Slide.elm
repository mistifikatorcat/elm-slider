module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src, title, style, classList)
import Html.Events exposing (onClick)
import List exposing (drop, head)
import Maybe exposing (withDefault)
import String exposing (fromFloat, isEmpty)
import Config.Products exposing (Product)


-- SLIDE‐SPECIFIC MESSAGES

type SlideMsg
    = SelectColor Int
    | ToggleInner


view : Bool -> Int -> Int -> Int -> Product -> Html SlideMsg
view isInner selectedIdx maxSwatches _ product =
    let
        -- unwrap setImageUrl
        setUrl =
            withDefault "" product.setImageUrl

        -- pick the current color record
        maybeColor =
            head (drop selectedIdx product.colors)

        -- build the <img>
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

        -- badges
        badgeElems =
            List.concat
                [ if product.isNew then [ span [ class "badge" ] [ text "New" ] ] else []
                , if product.isSet then [ span [ class "badge" ] [ text "Set" ] ] else []
                ]

        placeholderBadges =
            if List.isEmpty badgeElems then
                [ span [ class "badge placeholder" ] [] ]
            else
                []

        -- swatches
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

        placeholderCount =
            maxSwatches - List.length product.colors

        placeholderSpans =
            List.repeat placeholderCount (span [ class "swatch placeholder" ] [])

        -- feature text
        featureSpan =
            if isEmpty product.feature then
                []
            else
                [ span [ class "slide-feature" ] [ text product.feature ] ]

        -- choose toggle symbol
        toggleSymbol =
            if isInner then
                "×"
            else
                "+"
    in
    div [ class "slide" ]
        [ -- IMAGE + toggle-button (omit for sets)
          div [ class "slide-image-wrapper" ]
                ( imageElement
                :: if not product.isSet then
                        [ button
                            [ onClick ToggleInner
                            , classList [ ( "slide-toggle", True ), ( "open", isInner ) ]
                            ]
                            [ span [ class "toggle-text" ] [ text (if isInner then "Close" else "Show inside") ]
                            , span [ class "toggle-icon" ]
                                [ text "+" ]
                            ]
                        ]
                    else
                        []
    )


          -- CONTENT
        , div [ class "slide-content" ]
            (  -- badges row
               [ div [ class "slide-badges" ] (badgeElems ++ placeholderBadges) ]

               -- title + feature + prices
             ++ [ div [ class "slide-titles-prices" ]
                    ( [ div [ class "slide-title" ] (text product.title :: featureSpan) ]
                      ++ [ span [ class "slide-price" ]
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

               -- swatches row
             ++ [ div [ class "color-swatches" ] (swatchElems ++ placeholderSpans) ]

               -- description
             ++ [ div [ class "slide-desc" ] [ text product.description ] ]
            )
        ]
