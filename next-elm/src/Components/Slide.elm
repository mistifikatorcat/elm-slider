module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src, title, style)
import Html.Events exposing (onClick)
import List exposing (drop, head)
import Maybe exposing (withDefault)
import String exposing (fromFloat, isEmpty)
import Config.Products exposing (Product)


-- MESSAGES

type SlideMsg
    = SelectColor Int
    | ToggleInner


view : Bool -> Int -> Int -> Int -> Product -> Html SlideMsg
view isInner selectedIdx maxSwatches _ product =
    let
        -- 1) Image logic (Set vs. color swatches)
        setUrl =
            withDefault "" product.setImageUrl

        maybeColor =
            head (drop selectedIdx product.colors)

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
                                if isInner then c.innerUrl else c.outerUrl
                        in
                        img [ src urlToShow, class "slide-image" ] []

                    Nothing ->
                        text "No image!"

        -- 2) Badges (with placeholder if none)
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

        -- 3) Swatches (with placeholders)
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

        -- 4) Feature inside title (if non-empty)
        featureSpan =
            if isEmpty product.feature then
                []
            else
                [ span [ class "slide-feature" ] [ text product.feature ] ]
    in
    div [ class "slide" ]
        [ -- IMAGE + optional toggle-button
          div [ class "slide-image-wrapper" ]
            ( imageElement
              :: if not product.isSet then
                     [ button [ onClick ToggleInner, class "slide-toggle" ] [ text "⟳" ] ]
                 else
                     []
            )

          -- CONTENT
        , div [ class "slide-content" ]
            (  -- A) Badges row
               [ div [ class "slide-badges" ] (badgeElems ++ placeholderBadges) ]

               -- B) Title + Feature + Prices, all siblings
             ++ [ div [ class "slide-titles-prices" ]
                    -- Title (with feature inside)
                    ( [ div [ class "slide-title" ] (text product.title :: featureSpan) ]
                      -- Sale price as its own span
                    ++ [ span [ class "slide-price" ]
                           [ text ("$" ++ fromFloat product.price) ]
                       ]
                      -- Valued/MSRP price if present
                    ++ case product.setValue of
                           Just v ->
                               [ span [ class "slide-price-valued" ]
                                   [ text ("Valued at " ++ fromFloat v ++ "$") ]
                               ]

                           Nothing ->
                               []
                    )
                ]

               -- C) Color-swatches row
             ++ [ div [ class "color-swatches" ] (swatchElems ++ placeholderSpans) ]

               -- D) Description (pinned to bottom via CSS)
             ++ [ div [ class "slide-desc" ] [ text product.description ] ]
            )
        ]
