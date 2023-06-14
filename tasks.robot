*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${main_Table}=    Get orders
    FOR    ${row}    IN    @{main_Table}
        Print current row    ${row}
        Close the annoying modal
        Wait Until Keyword Succeeds    5x    200ms    Fill the form    ${row}
        Wait Until Keyword Succeeds    5x    200ms    Collect the results    ${row}
    END


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${my_Table}=    Read table from CSV    orders.csv    header=True
    RETURN    ${my_Table}

Print current row
    [Arguments]    ${order}
    Log To Console    ${order}

Close the annoying modal
    Wait And Click Button    //button[contains(.,'OK')]

Fill the form
    [Arguments]    ${order}
    Wait Until Element Is Enabled    head
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    //*[@placeholder="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button When Visible    //*[@id="preview"]
    [Teardown]    Click Button When Visible    //*[@id="order"]

Collect the results
    [Arguments]    ${order}
    Screenshot    //*[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}Order_${order}[Order number].png
    ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
    Html To Pdf    ${pdf}    ${OUTPUT_DIR}${/}receipts${/}receipt_${order}[Order number].pdf

Store the receipt as a PDF file
    [Arguments]    ${pdfName}
    Wait Until Element Is Visible    id:receipt
    ${pdfContent}=    Get Element Attribute    id:receipt    outerHTML
