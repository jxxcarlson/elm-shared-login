module Common.Style
    exposing
        ( button
        , activeButton
        , noAutocapitalize
        , noAutocorrect
        , preWrap
        )

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input
import Element.Lazy
import Html.Attributes


button : List (Element.Attr () msg)
button =
    [ Background.color black, Font.color grey, Element.paddingXY 10 6 ] ++ basicButtonsStyle


activeButton : Bool -> List (Element.Attr () msg)
activeButton active =
    case active of
        True ->
            activeButtonStyle

        False ->
            button


noAutocapitalize =
    Element.htmlAttribute (Html.Attributes.attribute "autocapitalize" "none")


noAutocorrect =
    Element.htmlAttribute (Html.Attributes.attribute "autocorrect" "off")


preWrap =
    Element.htmlAttribute (Html.Attributes.attribute "white-space" "pre-wrap")



--
-- PARAMETERS
--


buttonFontSize =
    Font.size 16



--
-- HELPERS
--


basicButtonsStyle =
    [ buttonFontSize
    , pointer
    , mouseDown [ buttonFontSize, Background.color mouseDownColor ]
    ]


activeButtonStyle : List (Element.Attr () msg)
activeButtonStyle =
    [ Background.color blue, Font.color grey, Element.paddingXY 10 6 ] ++ basicButtonsStyle



--
-- COLORS
--


grey =
    Element.rgb 0.8588 0.8549 0.8392


white =
    Element.rgb 1 1 1


black =
    Element.rgb 0.3 0.3 0.3


mouseOverColor =
    Element.rgb 0.0 0.6 0.9


mouseDownColor =
    Element.rgb 0.7 0.1 0.1


blue =
    Element.rgb 0.15 0.15 1.0
