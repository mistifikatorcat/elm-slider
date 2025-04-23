module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Config.Products exposing (Product)


-- A little Msg for slide-specific interactivity
type SlideMsg
    = SelectColor Int
    | ToggleInner


view : Int -> Product -> Html SlideMsg
view productIndex product =
    let
        -- pick the first color by default; you can wire SelectColor into your top-level Model later
        selectedColorIndex =
            0

        maybeColor =
            List.drop selectedColorIndex product.colors |> List.head

        badge txt =
            span [ class "badge" ] [ text txt ]

        titleWithFeatures =
            product.title
                ++ (if List.isEmpty product.features then ""
                    else " — " ++ String.join ", " product.features
                   )
    in
    div [ class "slide" ]
        [ -- global badges
          if product.isNew then badge "New" else text ""
        , if product.isSet then badge "Set" else text ""
        , div [ class "slide-title" ] [ text titleWithFeatures ]
        , div [ class "slide-price" ] [ text ("$" ++ String.fromFloat product.price) ]

        -- image area:
        , case ( product.isSet, maybeColor ) of
            ( True, _ ) ->
                img
                    [ class "slide-image"
                    , src (Maybe.withDefault "" product.setImageUrl)
                    ]
                    []

            ( False, Just color ) ->
                div [ class "image-switcher" ]
                    [ img [ src color.outerUrl, class "slide-image" ] []
                    , button [ onClick ToggleInner, class "small-btn" ]
                        [ text "Switch view" ]
                    ]

            _ ->
                text "No image!"

        -- color swatches (only for non-set products)
        , if not product.isSet then
            div [ class "color-swatches" ]
                (List.indexedMap
                    (\i c ->
                        span
                            [ class ("swatch" ++ if i == selectedColorIndex then " selected" else "")
                            , onClick (SelectColor i)
                            ]
                            ([ text c.name ] ++ if c.isNew then [ badge "New" ] else [])
                    )
                    product.colors
                )
          else
            text ""

        , div [ class "slide-desc" ] [ text product.description ]
        ]
