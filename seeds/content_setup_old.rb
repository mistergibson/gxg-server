#
module GxGwww
    module Setup
        #
        def self.setup_formats()
            # Themes are unformatted - free-form.
            format_template = GxG::DB[:roles][:formats].format_template()
            file_format = {:mime=>"application/octet-stream", :meta => {}, :file_segments => []}
            component_format = {:component=>"<component-class>", :settings => {}, :options => {}, :script=>"", :content=>[]}
            app_format = {:component => "application", :requirements => [], :options=>{}, :script=>"", :content=>[]}
            lib_format = {:component => "library", :type => "text/ruby", :requirements => [], :options=>{}, :script=>"", :content=>[]}
            # page_format = {:component => "page", :requirements => [], :page_title => "Untitled", :accesskey => "", :class => "",
            # :contenteditable => false, :data => {}, :dir => "ltr", :draggable => false, :dropzone => "", :id => "", :lang => "en",
            # :spellcheck => false, :style => {}, :tabindex => 0, :translate => "no", :script => "", :theme => "default", :auto_start => [],
            # :content => []}
            page_format = {
                :component => "page",
                :requirements => [],
                :auto_start => [],
                :settings => {:page_title => "Untitled Page", :theme => "default", :accesskey => "", :contenteditable => false, :dir => "ltr", :draggable => false, :dropzone => "", :lang => "en", :spellcheck => false, :translate => "no"},
                :options => {:style => {}, :states => ["page"], :tabindex => 0},
                :script => "",
                :content => []
            }
            #
            component_manifest = {
                :header => {:uuid => :"406027b1-bd6a-4303-a62d-84d612d60f4a", :version => 0.0, :ufs => "org.gxg.gui.component.header", :title => "Header", :mime_types => []},
                :navigator => {:uuid => :"52804511-921e-408d-8a47-5ddebdffb6ba", :version => 0.0, :ufs => "org.gxg.gui.component.navigator", :title => "Navigator", :mime_types => []},
                :section => {:uuid => :"433d8344-41ae-43c0-b9b3-8e3734c51e60", :version => 0.0, :ufs => "org.gxg.gui.component.section", :title => "Section", :mime_types => []},
                :article => {:uuid => :"18ee5cc8-bd0f-4cb4-98ea-d2512f818502", :version => 0.0, :ufs => "org.gxg.gui.component.article", :title => "Article", :mime_types => []},
                :aside => {:uuid => :"4a3fa48a-a180-4484-87f7-daada6006996", :version => 0.0, :ufs => "org.gxg.gui.component.aside", :title => "Aside", :mime_types => []},
                :footer => {:uuid => :"d0f32b6a-b899-4ddc-895c-55012a7111c9", :version => 0.0, :ufs => "org.gxg.gui.component.footer", :title => "Footer", :mime_types => []},
                :form => {:uuid => :"1f70d20f-2bd3-4181-bf9b-ee175b0102e6", :version => 0.0, :ufs => "org.gxg.gui.component.form", :title => "Form", :mime_types => []},
                :clickable => {:uuid => :"3d4849b0-f7df-4c2a-8570-32bab0111f48", :version => 0.0, :ufs => "org.gxg.gui.component.clickable", :title => "Clickable", :mime_types => []},
                :fieldset => {:uuid => :"d35e58e4-0c77-42b8-9e28-bb417d50a3d7", :version => 0.0, :ufs => "org.gxg.gui.component.fieldset", :title => "Fieldset", :mime_types => []},
                :text_input => {:uuid => :"b950191d-fb36-4a77-9e02-77409d9fbdb7", :version => 0.0, :ufs => "org.gxg.gui.component.input.text", :title => "Text Input", :mime_types => []},
                :password_input => {:uuid => :"3e12c288-c3e2-4fae-b558-68a57e48cc3b", :version => 0.0, :ufs => "org.gxg.gui.component.input.password", :title => "Password Input", :mime_types => []},
                :reset_input => {:uuid => :"c0df68b8-ade4-4aa7-8217-084880e38b61", :version => 0.0, :ufs => "org.gxg.gui.component.input.reset", :title => "Reset Input", :mime_types => []},
                :radio_button => {:uuid => :"9a281d07-fa75-439b-bc7b-1beb8d1ea4b5", :version => 0.0, :ufs => "org.gxg.gui.component.button.radio", :title => "Radio Button", :mime_types => []},
                :color_picker => {:uuid => :"73bb5304-c737-4654-a782-016f3d93aadf", :version => 0.0, :ufs => "org.gxg.gui.component.picker.color", :title => "Color Picker", :mime_types => []},
                :date_picker => {:uuid => :"37d3fa2b-af8f-4198-9bf8-86c6342f6b29", :version => 0.0, :ufs => "org.gxg.gui.component.picker.date", :title => "Date Picker", :mime_types => []},
                :datetime_local => {:uuid => :"19b269ac-6bc2-4c72-b32d-36b9b0180fb1", :version => 0.0, :ufs => "org.gxg.gui.component.input.datetime.local", :title => "DateTime Local", :mime_types => []},
                :email_input => {:uuid => :"80f96881-f408-4fe6-b15a-f38b9dbdaf29", :version => 0.0, :ufs => "org.gxg.gui.component.input.email", :title => "Email Input", :mime_types => []},
                :month_picker => {:uuid => :"6935d225-fab1-413b-8536-3eea1adae64d", :version => 0.0, :ufs => "org.gxg.gui.component.picker.month", :title => "Month Picker", :mime_types => []},
                :number_input => {:uuid => :"cb740651-8abe-40dc-81d6-a2d3e19181f2", :version => 0.0, :ufs => "org.gxg.gui.component.picker.number", :title => "Number Picker", :mime_types => []},
                :range_input => {:uuid => :"cda9416d-38e5-41e5-becb-f61d00fc6576", :version => 0.0, :ufs => "org.gxg.gui.component.input.range", :title => "Range Input", :mime_types => []},
                :search_input => {:uuid => :"91d7e811-292b-4d87-9f03-f462035bcab9", :version => 0.0, :ufs => "org.gxg.gui.component.input.search", :title => "Search Input", :mime_types => []},
                :phone_input => {:uuid => :"9221ded1-bee4-4d7b-9733-b355ac964fce", :version => 0.0, :ufs => "org.gxg.gui.component.input.phone", :title => "Phone Input", :mime_types => []},
                :time_picker => {:uuid => :"cb54991e-f885-4df0-a40f-b0c73ee5f8be", :version => 0.0, :ufs => "org.gxg.gui.component.picker.time", :title => "Time Picker", :mime_types => []},
                :url_input => {:uuid => :"89e806b9-b83d-47a8-9c9f-98c7c8ed6a2e", :version => 0.0, :ufs => "org.gxg.gui.component.input.url", :title => "URL Input", :mime_types => []},
                :week_picker => {:uuid => :"cf68bbf2-85b2-4b48-9363-6d62958e6268", :version => 0.0, :ufs => "org.gxg.gui.component.picker.week", :title => "Week Picker", :mime_types => []},
                :label => {:uuid => :"38772019-30b8-493b-a18a-4dbe09014d09", :version => 0.0, :ufs => "org.gxg.gui.component.label", :title => "Label", :mime_types => []},
                :text_area => {:uuid => :"508be60f-0899-4850-ab60-d57ee3998f4f", :version => 0.0, :ufs => "org.gxg.gui.component.text.area", :title => "Text Area", :mime_types => []},
                :output => {:uuid => :"53a88d40-629c-4471-bf52-94ac92e97aa0", :version => 0.0, :ufs => "org.gxg.gui.component.output", :title => "Output", :mime_types => []},
                :button_input => {:uuid => :"9e6e578d-8c13-43da-96ea-52b10f505a57", :version => 0.0, :ufs => "org.gxg.gui.component.input.button", :title => "Button Input", :mime_types => []},
                :submit_button => {:uuid => :"fabb80b8-6c68-4bc6-830b-8a8128965208", :version => 0.0, :ufs => "org.gxg.gui.component.input.button.submit", :title => "Submit Button", :mime_types => []},
                :click_block => {:uuid => :"e5d2e610-aa9b-4630-944d-cd3e470e4bae", :version => 0.0, :ufs => "org.gxg.gui.component.block.click", :title => "Click Block", :mime_types => []},
                :checkbox => {:uuid => :"925a8d6f-5284-48c2-a235-134cbbcb9c6b", :version => 0.0, :ufs => "org.gxg.gui.component.button.checkbox", :title => "Check Box", :mime_types => []},
                :selector => {:uuid => :"80b4cffc-9cca-461a-9a6c-b0843e57ccd3", :version => 0.0, :ufs => "org.gxg.gui.component.selector", :title => "Selector", :mime_types => []},
                :block => {:uuid => :"3d6bf1ce-b5df-4ec4-a26e-9d9e25ced8c9", :version => 0.0, :ufs => "org.gxg.gui.component.block", :title => "Block", :mime_types => []},
                :text => {:uuid => :"5f562410-0149-4c27-953f-0a531a8c695e", :version => 0.0, :ufs => "org.gxg.gui.component.text", :title => "Text", :mime_types => []},
                :list => {:uuid => :"4afe74f2-e9e7-446b-896a-fdb940c62e8b", :version => 0.0, :ufs => "org.gxg.gui.component.list.unordered", :title => "List", :mime_types => []},
                :ordered_list => {:uuid => :"fbdaba5d-aac0-4f64-8208-cd959f32f0fb", :version => 0.0, :ufs => "org.gxg.gui.component.list.ordered", :title => "Ordered List", :mime_types => []},
                :list_item => {:uuid => :"58213b45-5d5d-4fad-be5d-dc1dd37c5e2a", :version => 0.0, :ufs => "org.gxg.gui.component.list.item", :title => "List Item", :mime_types => []},
                :anchor => {:uuid => :"e333fb5f-14ea-41f7-b2a4-fef1b528faec", :version => 0.0, :ufs => "org.gxg.gui.component.link.anchor", :title => "Link Anchor", :mime_types => []},
                :external_link => {:uuid => :"223f1464-af75-4ffc-b137-0f13a93480b2", :ufs => "org.gxg.gui.component.link.external", :title => "External Link", :mime_types => []},
                :button => {:uuid => :"1890d372-b8fc-4b78-ba1e-5bd0f33e5c40", :version => 0.0, :ufs => "org.gxg.gui.component.button", :title => "Button", :mime_types => []},
                :image => {:uuid => :"5a5ae8dc-d09d-47f8-a059-cd147c6d1def", :version => 0.0, :ufs => "org.gxg.gui.component.image", :title => "Image", :mime_types => []},
                :video => {:uuid => :"72b3b65e-6a41-4c1a-8d9f-ea63aac34fa1", :version => 0.0, :ufs => "org.gxg.gui.component.video", :title => "Video", :mime_types => []},
                :canvas => {:uuid => :"fc48597e-a584-40e5-bbb0-738e723b5d8c", :version => 0.0, :ufs => "org.gxg.gui.component.canvas", :title => "Canvas", :mime_types => []},
                :script => {:uuid => :"160a19ca-1639-445e-9ad7-ff2a61b38f9a", :version => 0.0, :ufs => "org.gxg.gui.component.script", :title => "Script", :mime_types => []},
                :application_viewport => {:uuid => :"c0f8e94e-d1ad-41d7-ab42-9d1144a922c0", :version => 0.0, :ufs => "org.gxg.gui.component.application.viewport", :title => "Application Viewport", :mime_types => []},
                :search_form => {:uuid => :"b9230b9c-fe27-484b-a9ce-6f7c1b540ae9", :version => 0.0, :ufs => "org.gxg.gui.component.form.search", :title => "Search Form", :mime_types => []},
                :popupmenu => {:uuid => :"7245f529-b121-438a-86f9-5f55e0077cc3", :version => 0.0, :ufs => "org.gxg.gui.component.menu.popup", :title => "Popup Menu", :mime_types => []},
                :table => {:uuid => :"7c02dd79-a22d-4e66-b33a-cdcce3e97e84", :version => 0.0, :ufs => "org.gxg.gui.component.table", :title => "Table", :mime_types => []},
                :table_header => {:uuid => :"2f2bd2d4-7727-4068-adf6-0b3fafc7f083", :version => 0.0, :ufs => "org.gxg.gui.component.table.header", :title => "Table Header", :mime_types => []},
                :table_row => {:uuid => :"4c0659d6-d2d1-41b6-bb9d-a8374dd5ace3", :version => 0.0, :ufs => "org.gxg.gui.component.table.row", :title => "Table Row", :mime_types => []},
                :table_cell => {:uuid => :"7a43933e-67e1-44d7-9cc6-f59eaf1cf97d", :version => 0.0, :ufs => "org.gxg.gui.component.table.cell", :title => "Table Data Cell", :mime_types => []},
                :block_table => {:uuid => :"e8c615b2-ced5-4440-b2de-1fc6ea718782", :version => 0.0, :ufs => "org.gxg.gui.component.block.table", :title => "Block Table", :mime_types => []},
                :block_table_header => {:uuid => :"2b554d56-445d-45cc-a9f6-90150f3009ca", :version => 0.0, :ufs => "org.gxg.gui.component.block.table.header", :title => "Block Table Header", :mime_types => []},
                :block_table_row => {:uuid => :"b614c7f0-7364-4afd-a61c-b00facd7f6fb", :version => 0.0, :ufs => "org.gxg.gui.component.block.table.row", :title => "Block Table Row", :mime_types => []},
                :block_table_cell => {:uuid => :"96110e43-28a4-49ff-87e7-71038c0fc5d3", :version => 0.0, :ufs => "org.gxg.gui.component.block.table.cell", :title => "Block Table Data Cell", :mime_types => []},
                :window => {:uuid => :"1dc5966f-448a-40ba-8583-7002f9ffbbbe", :version => 0.0, :ufs => "org.gxg.gui.component.window", :title => "Window", :mime_types => []},
                :dialog_box => {:uuid => :"ceaf333c-5bda-45d5-a4f0-77eb9b5ca3e3", :version => 0.0, :ufs => "org.gxg.gui.component.window.dialog", :title => "Dialog Box Window", :mime_types => []},
                :panel => {:uuid => :"df2cf49b-dd44-4174-aad7-b2bd40bf842e", :version => 0.0, :ufs => "org.gxg.gui.component.panel", :title => "Panel", :mime_types => []},
                :tree => {:uuid => :"961520f2-bb61-4190-bd01-da560701c552", :version => 0.0, :ufs => "org.gxg.gui.component.tree", :title => "Tree Selector", :mime_types => []},
                :tree_node => {:uuid => :"635737ad-0fc8-45e6-a1d8-7d55685aa98b", :version => 0.0, :ufs => "org.gxg.gui.component.tree.node", :title => "Tree Selector Node", :mime_types => []},
                :menu_bar => {:uuid => :"c071ebad-7d54-4da6-8b71-6ff9bc7de38f", :version => 0.0, :ufs => "org.gxg.gui.component.menu.bar", :title => "Menu Bar", :mime_types => []},
                :menu_entry => {:uuid => :"8cab3fd2-f37c-48e6-9f6a-3ae354390f93", :version => 0.0, :ufs => "org.gxg.gui.component.menu.entry", :title => "Menu Entry", :mime_types => []},
                :menu_item => {:uuid => :"898229dd-8c3d-4709-99df-584eb38c2a6b", :version => 0.0, :ufs => "org.gxg.gui.component.menu.item", :title => "Menu Item", :mime_types => []},
                :grid_container => {:uuid => :"0694a61d-a282-481b-8242-70caa652a781", :version => 0.0, :ufs => "org.gxg.gui.component.grid.container", :title => "Grid Container", :mime_types => []},
                :grid_x => {:uuid => :"de6bcb5b-e3df-4c4e-9d37-b47ba56f1457", :version => 0.0, :ufs => "org.gxg.gui.component.grid.x", :title => "Grid X", :mime_types => []},
                :grid_y => {:uuid => :"9b98f09e-e354-48d1-a481-bdf2684a2cae", :version => 0.0, :ufs => "org.gxg.gui.component.grid.y", :title => "Grid Y", :mime_types => []},
                :accordion => {:uuid => :"95359db4-485b-462a-ac57-635e9f1f131c", :version => 0.0, :ufs => "org.gxg.gui.component.accordion", :title => "Accordion", :mime_types => []},
                :accordion_item => {:uuid => :"4fa5769c-bb16-4b8b-b45c-010f0b4e2b15", :version => 0.0, :ufs => "org.gxg.gui.component.accordion.item", :title => "Accordion Item", :mime_types => []},
                :accordion_menu => {:uuid => :"9eb38d28-49b9-4f97-9cf5-7884cfda0bc7", :version => 0.0, :ufs => "org.gxg.gui.component.accordion.menu", :title => "Accordion Menu", :mime_types => []},
                :accordion_submenu => {:uuid => :"28c6f401-6679-4312-8bab-433aaf8af446", :version => 0.0, :ufs => "org.gxg.gui.component.accordion.submenu", :title => "Accordion Submenu", :mime_types => []},
                :accordion_menu_item => {:uuid => :"38b7da3a-56fb-42f0-8f3b-46f7f1619a61", :version => 0.0, :ufs => "org.gxg.gui.component.accordion.menu.item", :title => "Accordion Menu Item", :mime_types => []},
                :anchor_button => {:uuid => :"94792c72-b925-4858-8039-f8d05bcce6f4", :version => 0.0, :ufs => "org.gxg.gui.component.anchor.button", :title => "Anchor Button", :mime_types => []},
                :badge => {:uuid => :"015f5721-f14a-46a1-9c70-55b22ff70794", :version => 0.0, :ufs => "org.gxg.gui.component.badge", :title => "Badge", :mime_types => []},
                :breadcrumb => {:uuid => :"69e3c8e4-4490-49b8-99ae-7440a6186ae8", :version => 0.0, :ufs => "org.gxg.gui.component.breadcrumb", :title => "Breadcrumb", :mime_types => []},
                :breadcrumb_item => {:uuid => :"b41cf65d-5686-4381-84ea-dbfb5ef23392", :version => 0.0, :ufs => "org.gxg.gui.component.breadcrumb.item", :title => "Breadcrumb Item", :mime_types => []},
                :button_group => {:uuid => :"fc47cf1a-e754-49e7-a433-9cc644f2fb57", :version => 0.0, :ufs => "org.gxg.gui.component.button.group", :title => "Button Group", :mime_types => []},
                :callout => {:uuid => :"54e8d34a-bfde-4c51-9b01-258f79fc4644", :version => 0.0, :ufs => "org.gxg.gui.component.callout", :title => "Callout", :mime_types => []},
                :colored_label => {:uuid => :"e6f9eb2f-44e9-4cce-b801-f3f95bb06d85", :version => 0.0, :ufs => "org.gxg.gui.component.label.colored", :title => "Colored Label", :mime_types => []},
                :drilldown_menu => {:uuid => :"7ed43e15-5773-4202-b3eb-5a48aa5de28b", :version => 0.0, :ufs => "org.gxg.gui.component.drilldown.menu", :title => "Drilldown Menu", :mime_types => []},
                :drilldown_submenu => {:uuid => :"d7f6d04b-f09f-4a1b-8728-72bbc607b1fe", :version => 0.0, :ufs => "org.gxg.gui.component.drilldown.submenu", :title => "Drilldown Submenu", :mime_types => []},
                :drilldown_menu_item => {:uuid => :"ce8e036e-dfdf-4b91-854d-3bacab952af9", :version => 0.0, :ufs => "org.gxg.gui.component.drilldown.menu.item", :title => "Drilldown Menu Item", :mime_types => []},
                :dropdown_menu => {:uuid => :"f4011e39-d572-4188-bebb-7a0ff6e68742", :version => 0.0, :ufs => "org.gxg.gui.component.dropdown.menu", :title => "Dropdown Menu", :mime_types => []},
                :dropdown_submenu => {:uuid => :"25c78952-a37e-4635-a22e-3da45e2993eb", :version => 0.0, :ufs => "org.gxg.gui.component.dropdown.submenu", :title => "Dropdown Submenu", :mime_types => []},
                :dropdown_menu_item => {:uuid => :"460b4eab-9020-4d42-8075-e547e914c067", :version => 0.0, :ufs => "org.gxg.gui.component.dropdown.menu.item", :title => "Dropdown Menu Item", :mime_types => []},
                :equalizer => {:uuid => :"c29bf74e-6104-4572-beab-4d689a138260", :version => 0.0, :ufs => "org.gxg.gui.component.equalizer", :title => "Equalizer", :mime_types => []},
                :flexgrid_row => {:uuid => :"47c5e626-70aa-42fd-8f79-406d085cbd46", :version => 0.0, :ufs => "org.gxg.gui.component.flexgrid.row", :title => "Flexgrid Row", :mime_types => []},
                :flexgrid_column => {:uuid => :"cf23977e-4aca-48df-bc20-614d395afa6f", :version => 0.0, :ufs => "org.gxg.gui.component.flexgrid.column", :title => "Flexgrid Column", :mime_types => []},
                :embed => {:uuid => :"3a086cfe-afdd-4c4c-8370-cf3d0b24ff80", :version => 0.0, :ufs => "org.gxg.gui.component.embed", :title => "Embed", :mime_types => []},
                :media_object => {:uuid => :"f6933266-3ce4-46b4-b23e-d7d63a578ab7", :version => 0.0, :ufs => "org.gxg.gui.component.media.object", :title => "Media Object", :mime_types => []},
                :media_object_section => {:uuid => :"2d50d84c-dfd2-4acd-92e9-09a930055136", :version => 0.0, :ufs => "org.gxg.gui.component.media.object.section", :title => "Media Object Section", :mime_types => []},
                :menu => {:uuid => :"f5fd2f0b-55ab-495c-9e27-6d1494ae646f", :version => 0.0, :ufs => "org.gxg.gui.component.menu", :title => "Menu", :mime_types => []},
                :offcanvas_wrapper => {:uuid => :"d8e13a5f-820e-4969-9bba-5dac28904fb9", :version => 0.0, :ufs => "org.gxg.gui.component.offcanvas.wrapper", :title => "Offcanvas Wrapper", :mime_types => []},
                :offcanvas_wrapper_inner => {:uuid => :"4a8f8592-7b81-4b9c-a756-3e008be678e9", :version => 0.0, :ufs => "org.gxg.gui.component.offcanvas.wrapper.inner", :title => "Offcanvas Wrapper Inner", :mime_types => []},
                :offcanvas_left => {:uuid => :"0f6ef1aa-0f1a-43ab-9ec9-272ab44bef40", :version => 0.0, :ufs => "org.gxg.gui.component.offcanvas.left", :title => "Offcanvas Left", :mime_types => []},
                :offcanvas_right => {:uuid => :"f26ac4a6-2733-435f-bf3a-9dbf91625d49", :version => 0.0, :ufs => "org.gxg.gui.component.offcanvas.right", :title => "Offcanvas Right", :mime_types => []},
                :offcanvas_content => {:uuid => :"b38a4e3a-d690-4555-a338-8c89143a82f8", :version => 0.0, :ufs => "org.gxg.gui.component.offcanvas.content", :title => "Offcanvas Content", :mime_types => []},
                :orbit => {:uuid => :"a077eda6-5797-4fd5-8018-6742cf1ecaac", :version => 0.0, :ufs => "org.gxg.gui.component.orbit", :title => "Orbit", :mime_types => []},
                :orbit_container => {:uuid => :"c3678beb-a7fd-496b-9d1b-152ffffbb888", :version => 0.0, :ufs => "org.gxg.gui.component.orbit.container", :title => "Orbit Container", :mime_types => []},
                :orbit_previous => {:uuid => :"c27b623b-4046-4971-8d90-a037b68258f1", :version => 0.0, :ufs => "org.gxg.gui.component.orbit.previous", :title => "Orbit Previous", :mime_types => []},
                :orbit_next => {:uuid => :"d3cd44cb-5384-42e5-ae53-776b0e7470df", :version => 0.0, :ufs => "org.gxg.gui.component.orbit.next", :title => "Orbit Next", :mime_types => []},
                :orbit_slide => {:uuid => :"a1c99b0a-0c98-40b9-a891-234024c26afe", :version => 0.0, :ufs => "org.gxg.gui.component.orbit.slide", :title => "Orbit Slide", :mime_types => []},
                :orbit_navigator => {:uuid => :"705d95f5-5654-444d-8f39-16a9db0564db", :version => 0.0, :ufs => "org.gxg.gui.component.orbit.navigator", :title => "Orbit Navigator", :mime_types => []},
                :orbit_bullet => {:uuid => :"fcc33147-6222-4ed6-a75e-87966044bfcf", :version => 0.0, :ufs => "org.gxg.gui.component.orbit.bullet", :title => "Orbit Bullet", :mime_types => []},
                :pagination => {:uuid => :"2ec92a1f-7475-435d-b02d-6392df56aed3", :version => 0.0, :ufs => "org.gxg.gui.component.pagination", :title => "Pagination", :mime_types => []},
                :pagination_item => {:uuid => :"5db1f95e-4d10-4058-8726-8a5a8cc478a1", :version => 0.0, :ufs => "org.gxg.gui.component.pagination.item", :title => "Pagination Item", :mime_types => []},
                :progress_bar => {:uuid => :"dc8cec03-5fad-4b02-a9aa-65971d04e6e9", :version => 0.0, :ufs => "org.gxg.gui.component.progress.bar", :title => "Progress Bar", :mime_types => []},
                :progress_meter => {:uuid => :"cb131b60-9a03-4201-bceb-cb5a2c0f0629", :version => 0.0, :ufs => "org.gxg.gui.component.progress.meter", :title => "Progress Meter", :mime_types => []},
                :horizontal_slider => {:uuid => :"2f169eaa-5f4f-4a87-a13b-97fc132fc749", :version => 0.0, :ufs => "org.gxg.gui.component.slider.horizontal", :title => "Horizontal Slider", :mime_types => []},
                :vertical_slider => {:uuid => :"2f169eaa-5f4f-4a87-a13b-97fc132fc749", :version => 0.0, :ufs => "org.gxg.gui.component.slider.vertical", :title => "Vertical Slider", :mime_types => []},
                :sticky => {:uuid => :"b4919664-673f-4c35-a46f-1e3dd65f1742", :version => 0.0, :ufs => "org.gxg.gui.component.sticky", :title => "Sticky", :mime_types => []},
                :tab_set => {:uuid => :"49c5a2c6-a972-47c5-b4c9-33cfe3166b36", :version => 0.0, :ufs => "org.gxg.gui.component.tab.set", :title => "Tab Set", :mime_types => []},
                :tab_content => {:uuid => :"c5181355-0cc9-46fb-b7ed-8efd42a85a80", :version => 0.0, :ufs => "org.gxg.gui.component.tab.content", :title => "Tab Content", :mime_types => []},
                :thumbnail => {:uuid => :"6459fa8a-6d4a-407d-ad22-a790382091fc", :version => 0.0, :ufs => "org.gxg.gui.component.thumbnail", :title => "Thumbnail", :mime_types => []},
                :titlebar => {:uuid => :"b51f8029-54c2-4cd8-842e-b74770535d88", :version => 0.0, :ufs => "org.gxg.gui.component.titlebar", :title => "Titlebar", :mime_types => []},
                :titlebar_left => {:uuid => :"c4f29149-4c2b-473d-9fd6-122df4883b4c", :version => 0.0, :ufs => "org.gxg.gui.component.titlebar.left", :title => "Titlebar Left", :mime_types => []},
                :titlebar_right => {:uuid => :"a7c2a061-58ed-4b85-9472-413db2061897", :version => 0.0, :ufs => "org.gxg.gui.component.titlebar.right", :title => "Titlebar Right", :mime_types => []},
                :topbar => {:uuid => :"1e724b93-a940-4fbf-83a0-479c4f511f6d", :version => 0.0, :ufs => "org.gxg.gui.component.topbar", :title => "Topbar", :mime_types => []},
                :topbar_left => {:uuid => :"a5f1b341-d4dc-49f7-a972-5845c5803bd9", :version => 0.0, :ufs => "org.gxg.gui.component.topbar.left", :title => "Topbar Left", :mime_types => []},
                :topbar_right => {:uuid => :"3aa96c4e-cca3-4408-a1c8-902083d8536b", :version => 0.0, :ufs => "org.gxg.gui.component.topbar.right", :title => "Topbar Right", :mime_types => []}
            }
            #
            puts "Creating Component Formats..."
            #
            # the_format = format_template.clone
            # the_format[:uuid] = :"58230f5b-83c9-4569-bb82-8564fffd5d74"
            # the_format[:ufs] = "org.gxg.file"
            # the_format[:title] = "File"
            # the_format[:version] = 0.0001
            # the_format[:content] = file_format
            # if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
            #     GxG::DB[:roles][:formats].format_create(the_format)
            # else
            #     existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
            #     if existing_format
            #         the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
            #     end
            #     GxG::DB[:roles][:formats].format_update(the_format)
            # end
            #
            the_format = format_template.clone
            the_format[:uuid] = :"cceb380b-fbc7-4dc9-ab75-3bf2c43d697b"
            the_format[:ufs] = "org.gxg.gui.component.page"
            the_format[:title] = "Page"
            the_format[:version] = 0.0001
            the_format[:content] = page_format
            if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
                GxG::DB[:roles][:formats].format_create(the_format)
            else
                existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
                if existing_format
                    the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
                end
                GxG::DB[:roles][:formats].format_update(the_format)
            end
            #
            the_format = format_template.clone
            the_format[:uuid] = :"2884f52a-29fd-4ac6-add7-69f91f805fd3"
            the_format[:ufs] = "org.gxg.component.library"
            the_format[:title] = "Library"
            the_format[:version] = 0.0001
            the_format[:content] = lib_format
            if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
                GxG::DB[:roles][:formats].format_create(the_format)
            else
                existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
                if existing_format
                    the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
                end
                GxG::DB[:roles][:formats].format_update(the_format)
            end
            #
            the_format = format_template.clone
            the_format[:uuid] = :"04ce09a6-c6e8-43d9-90e3-69f34d3be0a3"
            the_format[:ufs] = "org.gxg.component.application"
            the_format[:title] = "Application"
            the_format[:version] = 0.0001
            the_format[:content] = app_format
            if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
                GxG::DB[:roles][:formats].format_create(the_format)
            else
                existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
                if existing_format
                    the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
                end
                GxG::DB[:roles][:formats].format_update(the_format)
            end
            #
            the_format = format_template.clone
            the_format[:uuid] = :"d2413191-af3a-486f-bb6f-22b43ba6569f"
            the_format[:ufs] = "org.gxg.component.viewer"
            the_format[:title] = "Viewer"
            the_format[:version] = 0.0001.to_d
            the_format[:content] = app_format
            if GxG::DB[:roles][:rom].format_list({:uuid => the_format[:uuid]}).size == 0
                GxG::DB[:roles][:rom].format_create(the_format)
            else
                existing_format = GxG::DB[:roles][:rom].format_load({:uuid => the_format[:uuid]})
                if existing_format
                    the_format[:version] = existing_format[:version] += 0.0001
                end
                GxG::DB[:roles][:rom].format_update(the_format)
            end
            #
            the_format = format_template.clone
            the_format[:uuid] = :"c986c0f5-d082-4c29-b66a-ff0cd03dfa65"
            the_format[:ufs] = "org.gxg.component.editor"
            the_format[:title] = "Editor"
            the_format[:version] = 0.0001.to_d
            the_format[:content] = app_format
            if GxG::DB[:roles][:rom].format_list({:uuid => the_format[:uuid]}).size == 0
                GxG::DB[:roles][:rom].format_create(the_format)
            else
                existing_format = GxG::DB[:roles][:rom].format_load({:uuid => the_format[:uuid]})
                if existing_format
                    the_format[:version] = existing_format[:version] += 0.0001
                end
                GxG::DB[:roles][:rom].format_update(the_format)
            end
            #
            component_manifest.each_pair do |component,stub|
                the_format = format_template.clone
                the_component_record = component_format.clone
                the_component_record[:component] = component.to_s
                the_format[:uuid] = stub[:uuid]
                the_format[:ufs] = stub[:ufs]
                the_format[:title] = stub[:title]
                the_format[:version] = 0.0001
                case component
                when :table
                end
                the_format[:content] = the_component_record
                if GxG::DB[:roles][:formats].format_list({:uuid => the_format[:uuid]}).size == 0
                    GxG::DB[:roles][:formats].format_create(the_format)
                else
                    existing_format = GxG::DB[:roles][:formats].format_load({:uuid => the_format[:uuid]})
                    if existing_format
                        the_format[:version] = (((existing_format[:version] += 0.0001) * 10000.0).to_i.to_f / 10000.0)
                    end
                    GxG::DB[:roles][:formats].format_update(the_format)
                end
            end
            # Sync all formats with othe DBs.
            puts "Syncronizing formats to other DB roles..."
            #
            format_list = []
            GxG::DB[:roles][:formats].format_list({}).each do |fmt_stub|
                format_list << GxG::DB[:roles][:formats].format_load({:uuid => fmt_stub[:uuid]})
            end
            #
            already = []
            GxG::DB[:roles].values.each do |the_db|
                unless already.include?(the_db)
                    the_db.synchronize_records({:operation => :merge_format, :data => format_list},GxG::DB[:administrator])
                    already << the_db
                end
            end
            true
        end
        #
        def self.setup_css_setup()
            resources = [
                {
                    :resource_type => "font-face",
                    :font_family => "Varela",
                    :font_style => "normal",
                    :font_weight => 400,
                    :format => "truetype",
                    :source => "/themes/setup/fonts/varela.ttf"
                },
                {
                    :resource_type => "font-face",
                    :font_family => "BlueHighway",
                    :font_style => "normal",
                    :font_weight => 400,
                    :format => "woff",
                    :source => "/themes/setup/fonts/bluehighway-condensed.woff"
                },
                {
                    :resource_type => "font-face",
                    :font_family => "Futura",
                    :font_style => "normal",
                    :font_weight => 400,
                    :format => "woff",
                    :source => "/themes/setup/fonts/futura-condensed.woff"
                }
            ]
            css = {
                :"body.page"=>{
                    :"background-image"=>"url('/themes/setup/images/earth-tropical-storm.jpg')",
                    :"background-repeat"=>"no-repeat",
                    :"background-size"=>"cover",
                    :"font-family" => "Varela"
                },
                :"button" => {:"font-family" => "Varela"},
                :"input" => {:"font-family" => "Varela"},
                :".table"=>{:display=>"table", :margin=>0, :padding=>0},
                :".th"=>{:display=>"table-header", :margin=>0, :padding=>0},
                :".tr"=>{:display=>"table-row", :margin=>0, :padding=>0},
                :".td"=>{:display=>"table-cell", :margin=>0, :padding=>0},
                :".default-background-color" => {:"background-color" => "#f2f2f2"},
                :".default-highlite-color" => {:"background-color" => "#87acd5"}
            }
            #
            if GxG::VFS.exist?("/Public/www/content/themes/setup")
                GxG::VFS.rmfile("/Public/www/content/themes/setup")
            end
            new_css = GxG::VFS.mkfile("/Public/www/content/themes/setup")
            new_css.get_reservation
            puts "Setting up Setup CSS ..."
            # css.keys.each do |the_key|
            #     new_css[(the_key)] = css[(the_key)]
            # end
            new_css[:resources] = resources
            new_css[:rules] = css
            # Gather up components
            #
            puts "Setting public permissions ..."
            new_css.set_permissions(:"00000000-0000-4000-0000-000000000000", {:read => true})
            new_css.deactivate
            true
        end
        #
        def self.setup_css_default()
            resources = [
                {
                    :resource_type => "font-face",
                    :font_family => "Varela",
                    :font_style => "normal",
                    :font_weight => 400,
                    :format => "truetype",
                    :source => "/themes/setup/fonts/varela.ttf"
                },
                {
                    :resource_type => "font-face",
                    :font_family => "BlueHighway",
                    :font_style => "normal",
                    :font_weight => 400,
                    :format => "woff",
                    :source => "/themes/setup/fonts/bluehighway-condensed.woff"
                },
                {
                    :resource_type => "font-face",
                    :font_family => "Futura",
                    :font_style => "normal",
                    :font_weight => 400,
                    :format => "woff",
                    :source => "/themes/setup/fonts/futura-condensed.woff"
                }
            ]
            css = {
                :"body.page"=>{
                    :"background-image"=>"url('/themes/setup/images/earth-tropical-storm.jpg')",
                    :"background-repeat"=>"no-repeat",
                    :"background-size"=>"cover",
                    :"font-family" => "Varela"
                },
                :"button" => {:"font-family" => "Varela"},
                :"input" => {:"font-family" => "Varela"},
                :".table"=>{:display=>"table", :margin=>0, :padding=>0},
                :".th"=>{:display=>"table-header", :margin=>0, :padding=>0},
                :".tr"=>{:display=>"table-row", :margin=>0, :padding=>0},
                :".td"=>{:display=>"table-cell", :margin=>0, :padding=>0},
                :".default-background-color" => {:"background-color" => "#f2f2f2"},
                :".default-highlite-color" => {:"background-color" => "#87acd5"}
            }
            #
            if GxG::VFS.exist?("/Public/www/content/themes/default")
                GxG::VFS.rmfile("/Public/www/content/themes/default")
            end
            new_css = GxG::VFS.mkfile("/Public/www/content/themes/default")
            new_css.get_reservation
            puts "Setting up Default CSS ..."
            new_css[:resources] = resources
            new_css[:rules] = css
            # Gather up components
            #
            puts "Setting public permissions ..."
            new_css.set_permissions(:"00000000-0000-4000-0000-000000000000", {:read => true})
            new_css.deactivate
            true
        end
        #
        def self.setup_ace_lib()
            # Note: option --> :local => true/false : eval on instance (true) or in general (false)
            # content source record format: {:component => "script", :type => "text/ruby", :script => ""}
            lib = {:component => "library", :type => "text/javascript", :requirements => [], :options=>{:src => "/javascript/ace/ace.js", :charset => "utf-8", :global => "ace"}, :script=>"", :content=>[]}
            lib[:script] = "
            module GxG
                module Libraries
                    module Ace
                        class Editor
                            def initialize(the_component=nil, the_type=nil, options={})
                                unless the_component
                                    raise ArgumentError, 'You MUST provide a valid component'
                                end
                                if the_component.is_a?(::GxG::Gui::Page)
                                    raise ArgumentError, 'You cannot declare the page as an editor object'
                                end
                                unless ['text/ruby','text/javascript'].include(the_type.to_s)
                                    raise ArgumentError, ('Invalid type: ' + the_type.to_s)
                                end
                                # TODO: add element_id method to all GxG::Gui components
                                the_editor = nil
                                the_dom_element = the_component.element
                                %x{
                                    the_editor = ace.edit(the_dom_element.getAttribute('id'));
                                    the_editor.setTheme('ace/theme/chrome');
                                    if (the_type == 'text/javascript') {
                                        the_editor.session.setMode('ace/mode/javascript');
                                    } else {
                                        the_editor.session.setMode('ace/mode/ruby');
                                    };
                                    the_editor.getSession().setUseWrapMode(false);
                                }
                                @editor = the_editor
                                self
                            end
                            #
                            def get_content()
                                the_editor = @editor
                                the_data = ''
                                %x{
                                    the_data = the_editor.getValue();
                                }
                                the_data
                            end
                            #
                            def set_content(the_data=nil)
                                if the_data.is_a?(::String)
                                    the_editor = @editor
                                    %x{
                                        the_editor.setValue(the_data);
                                    }
                                    true
                                else
                                    false
                                end
                            end
                            #
                            def resize()
                                the_editor = @editor
                                %x{
                                    the_editor.resize();
                                }
                                true
                            end
                        end
                    end
                end
            end
            ".encode64
            #
            #
            if GxG::VFS.exist?("/Public/www/software/libraries/ace")
                GxG::VFS.rmfile("/Public/www/software/libraries/ace")
            end
            new_lib = GxG::VFS.mkfile("/Public/www/software/libraries/ace")
            new_lib.get_reservation
            puts "Setting up ACE Library ..."
            lib.keys.each do |the_key|
                new_lib[(the_key)] = lib[(the_key)]
            end
            # new_app[:content] << persisted_nativelib
            puts "Setting public permissions ..."
            new_lib.set_permissions(:"00000000-0000-4000-0000-000000000000", {:execute => true, :read => true})
            new_lib.deactivate
            true
        end
        #
        def self.setup_browser_app()
            # Application to browse the Public VFS.
            app = {:component => "application", :requirements => [], :options=>{:credentialed=>true, :unique=>true, :category=>"System"}, :script=>"", :content=>[]}
            app[:script] = "
            def vfs_tree()
                @heap[:vfs_tree]
            end
            #
            def vfs_tree_profile(the_path=nil,new_profile=nil)
                result = nil
                if the_path.is_a?(::String)
                    the_path_array = the_path.split('/')
                    the_heap_path_array = []
                    the_path_array.each_with_index do |the_element, the_index|
                        if the_element.size > 0
                            if the_index = (the_path_array.size - 1)
                                the_heap_path_array << ('/:' + the_element.to_s)
                            else
                                the_heap_path_array << ('/:' + the_element.to_s + '/:content')
                            end
                        end
                    end
                    the_heap_path = the_heap_path_array.join()
                    if new_profile
                        result = self.vfs_tree().set_at_path(the_heap_path,new_profile)
                    else
                        result = self.vfs_tree().get_at_path(the_heap_path)
                    end
                end
                result
            end
            #
            def fetch_vfs_tree_profile(the_path=nil,&block)
                result = self.vfs_tree_profile(the_path)
                if result
                    if block.respond_to?(:call)
                        block.call(result)
                    end
                else
                    if block.respond_to?(:call)
                        a_path = ::Pathname.new(the_path)
                        GxG::CONNECTION.entries({:location => (a_path.dirname.to_s)}) do |response|
                            if response.is_a?(::Hash)
                                response[:result].each do |the_profile|
                                    if the_profile[:title] == a_path.basename.to_s
                                        unless the_profile[:content].is_a?(::Hash)
                                            the_profile[:content] = {}
                                        end
                                        self.vfs_tree_profile(the_path,the_profile)
                                        block.call(the_profile)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                result
            end
            #
            def refresh_vfs_tree_profile(the_path=nil,&block)
                self.fetch_vfs_tree_profile(the_path) do |current_profile|
                    # current_profile[:content] = {}
                    GxG::CONNECTION.entries({:location => (the_path.to_s)}) do |response|
                        if response.is_a?(::Hash)
                            if response[:result].is_a?(::Array)
                                new_content = {}
                                response[:result].each do |the_profile|
                                    new_content[(the_profile[:title].to_s.to_sym)] = the_profile
                                end
                                new_content = (new_content.sort_by {|k,v| v[:title]}).to_h
                                current_profile[:content] = new_content
                                # Review: THIS step *should* not be needed, but ...
                                self.vfs_tree_profile(the_path,current_profile)
                                #
                                if block.respond_to?(:call)
                                    block.call(current_profile)
                                end
                            end
                        end
                    end
                    #
                end
            end
            #
            def create_object(details=nil)
                # details: {:operation => <the-op>, :path => the_selection, :profile => the_profile, :tree => tree_view, :list => list_view}
                if details.is_a?(::Hash)
                    if ['directory','virtual_directory','persisted_array'].include?(details[:profile][:type].to_s)
                        the_starting_path = details[:path]
                    else
                        the_starting_path = File.dirname(details[:path])
                    end
                    GxG::DISPLAY_DETAILS[:object].vfs_dialog(self, {:type => :save, :path => the_starting_path}) do |response|
                        if response.is_a?(::Hash)
                            # response: {:action => :save, :path => result_path}
                            unless response[:action] == :cancel
                                #
                                path_prefix = File.dirname(response[:path])
                                the_filename = ''
                                File.basename(response[:path]).to_s.chars.each do |the_char|
                                    if the_char.match(/[a-zA-Z0-9\-\_\.]/)
                                        the_filename = (the_filename + the_char)
                                    end
                                end
                                # distill a valid VFS operation with details:
                                vfs_op = nil
                                the_path = nil
                                the_format = nil
                                case details[:operation].to_s
                                when 'new_css_file'
                                    if File.extname(the_filename) == '.css'
                                        the_path = (path_prefix + '/' + the_filename)
                                    else
                                        the_path = (path_prefix + '/' + the_filename + '.css')
                                    end
                                    if the_path
                                        vfs_op = 'mkfile'
                                    end
                                when 'new_js_file'
                                    if File.extname(the_filename) == '.js'
                                        the_path = (path_prefix + '/' + the_filename)
                                    else
                                        the_path = (path_prefix + '/' + the_filename + '.js')
                                    end
                                    if the_path
                                        vfs_op = 'mkfile'
                                    end
                                when 'new_rb_file'
                                    if File.extname(the_filename) == '.rb'
                                        the_path = (path_prefix + '/' + the_filename)
                                    else
                                        the_path = (path_prefix + '/' + the_filename + '.rb')
                                    end
                                    if the_path
                                        vfs_op = 'mkfile'
                                    end
                                when 'new_library'
                                    the_path = (path_prefix + '/' + the_filename)
                                    the_format = 'org.gxg.gui.component.library'
                                    vfs_op = 'mkfile'
                                when 'new_application'
                                    the_path = (path_prefix + '/' + the_filename)
                                    the_format = 'org.gxg.gui.component.application'
                                    vfs_op = 'mkfile'
                                when 'new_object'
                                    the_path = (path_prefix + '/' + the_filename)
                                    vfs_op = 'mkfile'
                                when 'new_theme'
                                    # Warning: this scheme for themes will probably change all around.
                                    the_path = (path_prefix + '/' + the_filename)
                                    # Theme objects are unstructured for now - no format.
                                    vfs_op = 'mkfile'
                                when 'new_page'
                                    the_path = (path_prefix + '/' + the_filename)
                                    the_format = 'org.gxg.gui.component.page'
                                    vfs_op = 'mkfile'
                                when 'new_folder'
                                    the_path = (path_prefix + '/' + the_filename)
                                    vfs_op = 'mkdir'
                                else
                                    log_warn('Unknown Create Operation: ' + details[:operation].to_s)
                                end
                                #
                                if vfs_op && the_path
                                    if the_format
                                        op_details = {:action => vfs_op, :path => the_path, :format => the_format}
                                    else
                                        op_details = {:action => vfs_op, :path => the_path}
                                    end
                                    error_handler = Proc.new { |response|
                                        # communication errors only
                                        log_warn(response.inspect)
                                        self.page.set_busy(false)
                                    }
                                    GxG::DISPLAY_DETAILS[:object].set_busy(true)
                                    GxG::CONNECTION.vfs(op_details,error_handler) do |vfs_response|
                                        if vfs_response.is_a?(::Hash)
                                            if vfs_response[:result] == true
                                                details[:list].select_item(nil)
                                                details[:list].update_appearance(details[:tree].node_at_path(path_prefix))
                                            else
                                                log_warn('Error creating item: ' + vfs_response[:error].to_s)
                                            end
                                        end
                                        GxG::DISPLAY_DETAILS[:object].set_busy(false)
                                    end
                                end
                                #
                            end
                        end
                    end
                end
            end
            #
            def restore_appearance()
                # update the tree-view and list-view to reflect where you left off last session.
            end
            #
            def tree_select(the_node=nil)
                if the_node.is_a?(::GxG::Gui::TreeNode)
                    @state[:vfs_selection] = the_node.node_path()
                    if the_node.data.is_a?(::Hash)
                        list_view = GxG::DISPLAY_DETAILS[:object].find_object_by_title('list_view')
                        # FIXME: why is :content nil ??
                        if (the_node.data[:content] || {}).keys.size > 0
                            if list_view
                                list_view.update_appearance(the_node)
                            end
                        else
                            GxG::CONNECTION.entries({:location => @state[:vfs_selection]}) do |response|
                                if response.is_a?(::Hash)
                                    response[:result].each do |the_profile|
                                        unless the_profile[:content].is_a?(::Hash)
                                            the_profile[:content] = {}
                                        end
                                        the_node.data[:content][(the_profile[:title])] = the_profile
                                    end
                                    if list_view
                                        list_view.update_appearance(the_node)
                                    end
                                end
                            end
                        end
                    end
                    #
                end
            end
            #
            def build_tree(options={})
                tree_data = self.vfs_tree()
                viewport = self.get_viewport('browser_viewport')
                if viewport
                    tree_object = viewport.find_child('tree_view')
                    #
                    tree_object.set_processor(:select) do |the_node|
                        the_window = the_node.window()
                        if the_window
                            the_application = the_window.application
                            if the_application
                                the_application.tree_select(the_node)
                            end
                        end
                    end
                    #
                    tree_object.set_processor(:expand) do |the_node|
                        # NOTE: in order for this to work you MUST keep the title of the node = to the profile title.
                        # since deletions might occur - for now: just reload upon expand for fresh data.
                        comm_err_handler = Proc.new { |response|
                            GxG::DISPLAY_DETAILS[:object].set_busy(false)
                            log_warn(response.inspect)
                        }
                        GxG::CONNECTION.entries({:location => the_node.node_path()},comm_err_handler) do |response|
                            if response[:result].is_a?(::Array)
                                the_content = {}
                                old_content = the_node.data[:content]
                                response[:result].each do |the_profile|
                                    if old_content.keys.include?(the_profile[:title].to_sym)
                                        # transfer
                                        the_content[(the_profile[:title].to_sym)] = old_content[(the_profile[:title].to_sym)]
                                    else
                                        # add
                                        unless the_profile[:content].is_a?(::Hash)
                                            the_profile[:content] = {}
                                        end
                                        the_content[(the_profile[:title].to_sym)] = the_profile
                                    end
                                end
                                the_content = (the_content.sort_by {|k,v| v[:title]}).to_h
                                the_node.data[:content] = the_content
                                the_node.nodes.values.each do |a_node|
                                    a_node.destroy
                                end
                                the_icon = GxG::DISPLAY_DETAILS[:object].theme_icon('folder.svg')
                                the_content.each_pair do |selector, the_profile|
                                    if ['directory', 'virtual_directory', 'persisted_array'].include?(the_profile[:type])
                                        new_node = the_node.add_child(GxG::uuid_generate.to_s.to_sym, GxG::Gui::TreeNode, {:data => the_profile, :icon => the_icon, :label => the_profile[:title]})
                                        new_node.set_title(the_profile[:title])
                                    end
                                end
                                #
                                the_window = the_node.window()
                                if the_window
                                    the_window.commit_settings()
                                end
                                #
                                true
                            end
                        end
                        #
                    end
                    #
                    tree_object.set_processor(:collapse) do |the_node|
                        the_node.nodes.values.each do |a_node|
                            a_node.destroy
                        end
                        the_window = the_node.window()
                        if the_window
                            the_window.commit_settings()
                        end
                        #
                    end
                    #
                    if tree_object
                        tree_data.keys.each do |selector|
                            the_type = tree_data[(selector)][:type]
                            if ['directory', 'virtual_directory', 'persisted_array'].include?(the_type)
                                # determine icon - just a generic folder for now.
                                the_icon = GxG::DISPLAY_DETAILS[:object].theme_icon('folder.svg')
                                the_node = tree_object.add_child(GxG::uuid_generate.to_s.to_sym, GxG::Gui::TreeNode, {:data => tree_data[(selector)], :icon => the_icon, :label => selector.to_s})
                                the_node.set_title(selector.to_s)
                                # GxG::DISPLAY_DETAILS[:object].register_object(selector, the_node) ??
                            end
                        end
                        #
                    end
                end
            end
            #
            def open_editor(the_settings=nil)
                if the_settings
                    GxG::DISPLAY_DETAILS[:object].application_open({:name => 'object_editor'},the_settings)
                    true
                else
                    false
                end
            end
            #
            def run(settings={})
                if settings[:restore] == true
                    self.state_pull()
                    self.restore_appearance()
                end
                unless @heap[:vfs_tree].is_a?(::Hash)
                    @heap[:vfs_tree] = {}
                    GxG::CONNECTION.entries({:location => '/'}) do |response|
                        if response[:result].is_a?(::Array)
                            response[:result].each do |the_profile|
                                unless the_profile[:content].is_a?(::Hash)
                                    the_profile[:content] = {}
                                end
                                @heap[:vfs_tree][(the_profile[:title].to_s.to_sym)] = the_profile
                            end
                            the_window_resource = self.search_content('object_browser')
                            if the_window_resource
                                GxG::DISPLAY_DETAILS[:object].window_open(the_window_resource, self)
                                the_window = self.get_window('object_browser')
                                if the_window
                                    GxG::DISPLAY_DETAILS[:object].set_busy(true)
                                    self.build_tree()
                                    the_window.show()
                                    GxG::DISPLAY_DETAILS[:object].set_busy(false)
                                else
                                    log_warn('Could not find window object to open.')
                                end
                            else
                                log_warn('Could not find window resource to build.')
                            end
                        end
                    end
                end
            end
            ".encode64
            # Detail Pane:
            detail_text = {:component=>"text", :options=> {:title => "detail_info", :content => "Details:", :style => {:"font-size" => "10px", :padding => "0px 0px 0px 5px"}}, :content => [], :script => ""}
            detail_cell = {:component=>"block_table_cell", :options=> {}, :content => [(detail_text)], :script => ""}
            detail_row = {:component=>"block_table_row", :options=> {}, :content => [(detail_cell)], :script => ""}
            #
            details = {:component=>"block_table", :options=>{:title => "details", :track => {:width => "20%", :height => "100%"}, :style => {:clear => "both", :width => "100%", :height => "100%", :"overflow-y" => "scroll", :padding => "0px", :border => "1px", :"border-color" => "#c2c2c2", :"background-color" => "#c2c2c2", :margin => "0px"}}, :content=>[(detail_row)], :script=>""}
            details[:script] = "
            def update_appearance(the_frame=nil)
                #
                the_window = self.window()
                if the_window
                    readout = the_window.find_child('detail_info')
                else
                    readout = nil
                end
                readout_text = ''
                #
                if the_frame
                    the_path = the_frame.gxg_get_attribute(:nodepath)
                    if the_window
                        menu_bar = the_window.find_child('object_browser_menu',true)
                        the_application = the_window.application
                        if the_application && menu_bar
                            # debug
                            # puts ('Processing path: ' + the_path.inspect)
                            the_application.fetch_vfs_tree_profile(the_path) do |the_profile|
                                if the_profile
                                    readout_text = (readout_text + 'UUID:<br>' + the_profile[:uuid].to_s + '<br><br>')
                                    readout_text = (readout_text + 'Version:<br>' + the_profile[:version].to_s + '<br><br>')
                                    readout_text = (readout_text + 'Permissions:<br>')
                                    permission_list = []
                                    [
                                        {'new_entry' => [:create]},
                                        {'open_item' => [:read]},
                                        {'permissions' => [:write]},
                                        {'rename_item' => [:rename]},
                                        {'copy_item' => [:read]},
                                        {'move_item' => [:move]},
                                        {'delete_item' => [:destroy]}
                                    ].each do |the_record|
                                        can_do = true
                                        the_operation = the_record.keys[0]
                                        the_record[(the_operation)].each do |the_permission|
                                            if the_profile[:permissions][:effective][(the_permission)] == true
                                                unless permission_list.include?(the_permission)
                                                    permission_list << the_permission
                                                end
                                            else
                                                can_do = false
                                                break
                                            end
                                        end
                                        the_item = menu_bar.find_entry(the_operation)
                                        if the_item
                                            if can_do == true
                                                the_item.enable
                                            else
                                                the_item.disable
                                            end
                                        end
                                    end
                                    permission_list.each do |the_permission|
                                        readout_text = (readout_text + the_permission.to_s + '<br>')
                                    end
                                end
                            end
                        else
                            log_warn('Error aquiring Application or MenuBar object.')
                        end
                    else
                        log_warn('Error aquiring Window object.')
                    end
                    #
                else
                    if the_window
                        menu_bar = the_window.find_child('object_browser_menu',true)
                        the_application = the_window.application
                        the_tree = the_window.find_child('tree_view')
                        if the_tree && the_application && menu_bar
                            if the_tree.selection
                                # debug
                                # puts ('Processing tree path: ' + the_tree.selection.node_path().inspect)
                                the_application.fetch_vfs_tree_profile(the_tree.selection.node_path()) do |the_profile|
                                    readout_text = (readout_text + 'UUID:<br>' + the_profile[:uuid].to_s + '<br><br>')
                                    readout_text = (readout_text + 'Version:<br>' + the_profile[:version].to_s + '<br><br>')
                                    readout_text = (readout_text + 'Permissions:<br>')
                                    permission_list = []
                                    [
                                        {'new_entry' => [:create]},
                                        {'open_item' => [:read]},
                                        {'permissions' => [:write]},
                                        {'rename_item' => [:rename]},
                                        {'copy_item' => [:read]},
                                        {'move_item' => [:move]},
                                        {'delete_item' => [:destroy]}
                                    ].each do |the_record|
                                        can_do = true
                                        the_operation = the_record.keys[0]
                                        the_record[(the_operation)].each do |the_permission|
                                            if the_profile[:permissions][:effective][(the_permission)] == true
                                                unless permission_list.include?(the_permission)
                                                    permission_list << the_permission
                                                end
                                            else
                                                can_do = false
                                                break
                                            end
                                        end
                                        the_item = menu_bar.find_entry(the_operation)
                                        if the_item
                                            if can_do == true
                                                the_item.enable
                                            else
                                                the_item.disable
                                            end
                                        end
                                    end
                                    permission_list.each do |the_permission|
                                        readout_text = (readout_text + the_permission.to_s + '<br>')
                                    end
                                    #
                                end
                            else
                                ['new_entry','open_item','rename_item','move_item','permissions','delete_item'].each do |the_item_name|
                                    the_item = menu_bar.find_entry(the_item_name)
                                    if the_item
                                        the_item.disable
                                    end
                                end
                            end
                        else
                            unless the_tree
                                log_warn('Error aquiring Tree object.')
                            end
                            unless the_application
                                log_warn('Error aquiring Application object.')
                            end
                            unless menu_bar
                                log_warn('Error aquiring MenuBar object.')
                            end
                        end
                    else
                        log_warn('Error aquiring Window object.')
                    end
                end
                if readout
                    readout.html(readout_text)
                end
                #
                true
            end
            ".encode64
            #
            listview = {:component=>"list", :options=>{:title => "list_view", :style => {:clear => "both", :"list-style" => "none", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            listview[:script] = "
            def selection()
                @selection
            end
            #
            def select_item(the_frame=nil)
                the_window = self.window()
                if the_frame
                    if @selection
                        @selection.gxg_merge_style({:'background-color' => '#f2f2f2'})
                        @selection = nil
                    end
                    unless @selection
                        @selection = the_frame
                    end
                    @selection.gxg_merge_style({:'background-color' => '#87acd5'})
                else
                    @selection = nil
                end
                # update details pane
                detail_view = the_window.find_child('details')
                if detail_view
                    detail_view.update_appearance(@selection)
                else
                    log_warn('Unable to aquire details')
                end
            end
            #
            def open_item(the_frame)
                if the_frame
                    self.select_item(the_frame)
                    the_path = the_frame.gxg_get_attribute(:nodepath)
                    if the_path.is_a?(::String)
                        the_window = the_frame.window()
                        if the_window
                            the_tree = the_window.find_child('tree_view')
                        else
                            the_tree = nil
                        end
                        if the_tree
                            the_node = the_tree.node_at_path(the_path)
                            if the_node
                                the_profile = the_node.data.clone
                                if the_profile
                                    case the_profile[:type]
                                    when 'directory', 'virtual_directory', 'persisted_array'
                                        # move to this node in tree viewer
                                        the_tree.expand_path(the_node.node_path()) do
                                            the_tree.select(the_node)
                                        end
                                    when 'file'
                                        # TODO: add raw file editor later.
                                    when 'persisted_hash'
                                        # open object editor
                                        the_profile.delete(:content)
                                        GxG::DISPLAY_DETAILS[:object].application_open({:name => 'object_editor'}, {:profile => the_profile})
                                    end
                                end
                            else
                                # no node here
                                if the_window
                                    the_application = the_window.application
                                    if the_application
                                        the_application.fetch_vfs_tree_profile(the_path) do |the_profile|
                                            if the_profile
                                                a_profile = the_profile.clone
                                                case a_profile[:type]
                                                when 'directory', 'virtual_directory', 'persisted_array'
                                                    # move to this node in tree viewer
                                                    the_tree.expand_path(the_path) do
                                                        the_tree.select(the_tree.node_at_path(the_path))
                                                    end
                                                when 'file'
                                                    # TODO: add raw file editor later.
                                                when 'persisted_hash'
                                                    # open object editor
                                                    a_profile.delete(:content)
                                                    GxG::DISPLAY_DETAILS[:object].application_open({:name => 'object_editor'}, {:profile => a_profile})
                                                end
                                            else
                                                puts ('No profile for ' + the_path.to_s)
                                            end
                                            #
                                        end
                                    else
                                        puts 'No application found for window'
                                    end
                                end
                            end
                        end
                    end
                end
            end
            #
            def update_appearance(the_node=nil)
                if the_node
                    the_path = the_node.node_path()
                    the_content = the_node.data[:content]
                else
                    the_path = nil
                    the_content = nil
                end
                if the_content.is_a?(::Hash)
                    build_stack = []
                    the_content.each_pair do |selector, the_profile|
                        # determine the_icon
                        case the_profile[:type]
                        when 'directory', 'virtual_directory', 'persisted_array'
                            the_icon = GxG::DISPLAY_DETAILS[:object].theme_icon('folder.svg')
                        when 'file', 'application', 'library'
                            # sub-case mime type for better file icons ??
                            the_icon = GxG::DISPLAY_DETAILS[:object].theme_icon('file.svg')
                        when 'persisted_hash'
                            the_icon = GxG::DISPLAY_DETAILS[:object].theme_icon('object.svg')
                        end
                        #
                        node_frame = {:component=>'block_table', :options=>{}, :content=>[], :script=>''}
                        frame_row_one = {:component=>'block_table_row', :options=>{:nodepath => (the_path + '/' + the_profile[:title])}, :content=>[], :script=>''}
                        frame_row_one[:script] = \"
                        on(:dblclick) do |event|
                            the_window = self.window()
                            if the_window
                                list_view = the_window.find_child('list_view')
                                if list_view
                                    list_view.select_item(self)
                                    list_view.open_item(self)
                                end
                            end
                        end
                        on(:mouseup) do |event|
                            the_window = self.window()
                            if the_window
                                list_view = the_window.find_child('list_view')
                                if list_view
                                    list_view.select_item(self)
                                end
                            end
                        end
                        \".encode64
                        node_icon_cell = {:component=>'block_table_cell', :options=>{:style => {:width => 32}}, :content=>[], :script=>''}
                        node_label_cell = {:component=>'block_table_cell', :options=>{}, :content=>[], :script=>''}
                        icon = {:component=>'image', :options=>{:src=>(the_icon) , :width=>32, :height=>32, :style => {:clear => 'both'}}, :content=>[], :script=>''}
                        title = {:component=>'label', :options=>{:content => the_profile[:title], :style => {:'font-size' => '16px', :'text-align' => 'left', :float => 'left', :'vertical-align' => 'middle', :margin => '2px', :padding => '2px'}}, :content=>[], :script=>''}
                        # integrate item subcomponents:
                        node_icon_cell[:content] = [(icon)]
                        node_label_cell[:content] = [(title)]
                        frame_row_one[:content] = [(node_icon_cell),(node_label_cell)]
                        node_frame[:content] = [(frame_row_one)]
                        #
                        the_item = {:component=>'list_item', :options=>{:style => {:display => 'list-item', :'white-space' => 'nowrap'}}, :content=>[(node_frame)], :script=>''}
                        #
                        build_stack << the_item
                    end
                    #
                    self.children.values.reverse.each do |the_child|
                        the_child.destroy
                    end
                    #
                    GxG::DISPLAY_DETAILS[:object].build_components([{:parent => self.parent, :record => {:content => build_stack}, :element => self}])
                    #
                    self.select_item(nil)
                end
            end
            ".encode64
            list_div = {:component=>"block", :options=>{:title => "list_div", :track => {:width => "40%", :height => "100%"}, :style => {:clear => "both", :height => "100%", :"overflow-y" => "scroll", :border => "1px", :"border-color" => "#c2c2c2", :margin => "0px"}}, :content=>[(listview)], :script=>""}
            #
            tree = {:component=>"tree", :options=>{:title => "tree_view", :track => {:width => "40%", :height => "100%"}, :style => {:clear => "both", :overflow => "scroll", :border => "1px", :"border-color" => "#c2c2c2", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            #
            form_table = {:component=>"block_table", :options=>{:style => {:overflow => "hidden", :clear => "both", :width => "100%", :height => "100%", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            form_row = {:component=>"block_table_row", :options=>{:style => {:overflow => "hidden", :width => "100%", :height => "100%", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            form_cell_one = {:component=>"block_table_cell", :options=>{:style => {:overflow => "hidden", :width => "40%", :height => "100%", :float => "left", :padding => "0px", :margin => "0px", :position => "relative"}}, :content=>[], :script=>""}
            form_cell_one[:content] = [(tree)]
            form_cell_two = {:component=>"block_table_cell", :options=>{:style => {:overflow => "hidden", :width => "40%", :height => "100%", :float => "left", :padding => "0px", :margin => "0px", :position => "relative"}}, :content=>[], :script=>""}
            form_cell_two[:content] = [(list_div)]
            form_cell_three = {:component=>"block_table_cell", :options=>{:style => {:overflow => "hidden", :width => "20%", :height => "100%", :float => "right", :padding => "0px", :margin => "0px", :position => "relative"}}, :content=>[], :script=>""}
            form_cell_three[:content] = [(details)]
            form_row[:content] = [(form_cell_one),(form_cell_two),(form_cell_three)]
            form_table[:content] = [(form_row)]
            #
            viewport = {:component=>"application_viewport", :options=>{:title => "browser_viewport", :style => {:overflow => "hidden", :width => "100%", :height => "100%"}}, :content=>[(form_table)], :script=>""}
            #
            window = {:component => "window", :options => {:window_title => "Object Browser", :menu => "object_browser_menu", :top => 0, :left => 0, :width => 600, :height => 300, :scroll => false, :states => {:hidden => true}}, :script => "", :content => [(viewport)]}
            #
            puts "Building Main Window ..."
            persisted_window = GxG::DB[:roles][:software].try_persist(window, GxG::DB[:administrator])
            persisted_window.set_title("object_browser")
            # ----------------------------------------------------------------------------------------
            # Object Menu
            # Delete
            delete_item = {:component => "menu_item", :options => {:title => "delete_item", :content => "Delete ...", :data => {:operation => "delete_item"}}, :content => [], :script => ""}
            # Permissions
            permissions_item = {:component => "menu_item", :options => {:title => "permissions", :content => "Permissions ...", :data => {:operation => "permissions"}}, :content => [], :script => ""}
            # Copy
            copy_item = {:component => "menu_item", :options => {:title => "copy_item", :content => "Copy ...", :data => {:operation => "copy_item"}}, :content => [], :script => ""}
            # Move
            move_item = {:component => "menu_item", :options => {:title => "move_item", :content => "Move ...", :data => {:operation => "move_item"}}, :content => [], :script => ""}
            # Rename
            rename_item = {:component => "menu_item", :options => {:title => "rename_item", :content => "Rename ...", :data => {:operation => "rename_item"}}, :content => [], :script => ""}
            # Open
            open_item = {:component => "menu_item", :options => {:title => "open_item", :content => "Open", :data => {:operation => "open_item"}}, :content => [], :script => ""}
            # New >>
            new_css_file = {:component => "menu_item", :options => {:content => "CSS File ...", :data => {:operation => "new_css_file"}}, :content => [], :script => ""}
            new_rb_file = {:component => "menu_item", :options => {:content => "Ruby File ...", :data => {:operation => "new_rb_file"}}, :content => [], :script => ""}
            new_js_file = {:component => "menu_item", :options => {:content => "JavaScript File ...", :data => {:operation => "new_js_file"}}, :content => [], :script => ""}
            new_library = {:component => "menu_item", :options => {:content => "Library ...", :data => {:operation => "new_library"}}, :content => [], :script => ""}
            new_application = {:component => "menu_item", :options => {:content => "Application ...", :data => {:operation => "new_application"}}, :content => [], :script => ""}
            new_object = {:component => "menu_item", :options => {:content => "Object ...", :data => {:operation => "new_object"}}, :content => [], :script => ""}
            new_theme = {:component => "menu_item", :options => {:content => "Theme ...", :data => {:operation => "new_theme"}}, :content => [], :script => ""}
            new_page = {:component => "menu_item", :options => {:content => "Page ...", :data => {:operation => "new_page"}}, :content => [], :script => ""}
            new_folder = {:component => "menu_item", :options => {:content => "Folder ...", :data => {:operation => "new_folder"}}, :content => [], :script => ""}
            #
            new_entry = {:component => "menu_entry", :options => {:title => "new_entry", :content => "New"}, :content => [(new_folder),(new_page),(new_theme),(new_object),(new_application),(new_library),(new_js_file),(new_rb_file),(new_css_file)], :script => ""}
            #
            object_menu = {:component => "menu_entry", :options => {:content => "Object", :orientation => "verticle"}, :content => [(open_item),(new_entry),(rename_item),(copy_item),(move_item),(permissions_item),(delete_item)], :script => ""}
            object_menu_bar = {:component => "menu_bar", :options => {}, :content => [(object_menu)], :script => ""}
            object_menu_bar[:script] = "
            def select_item(the_menu_item=nil)
                if the_menu_item.is_a?(::GxG::Gui::MenuItem)
                    the_window = self.find_parent_type(::GxG::Gui::Window)
                    if the_window
                        the_selection = nil
                        list_view = the_window.find_child('list_view')
                        if list_view
                            if list_view.selection()
                                the_selection = list_view.selection().gxg_get_attribute(:nodepath)
                            end
                        end
                        tree_view = the_window.find_child('tree_view')
                        unless the_selection
                            if tree_view
                                if tree_view.selection()
                                    the_selection = tree_view.selection().node_path()
                                end
                            end
                        end
                        #
                        the_application = the_window.application()
                        if the_application && the_selection
                            the_application.fetch_vfs_tree_profile(the_selection) do |the_profile|
                                # Note: the_profile[:content] *should* be loaded at this point.
                                current_selection = {:path => the_selection, :profile => the_profile}
                                record = the_menu_item.data()
                                if record.is_any?(::Hash, ::GxG::Database::PersistedHash)
                                    case record[:operation].to_s
                                    when 'new_css_file', 'new_js_file', 'new_rb_file', 'new_library', 'new_application', 'new_object', 'new_theme', 'new_page', 'new_folder'
                                        # New: See line #418
                                        the_application.create_object({:operation => record[:operation].to_s, :path => the_selection, :profile => the_profile, :tree => tree_view, :list => list_view})
                                    when 'open_item'
                                        `alert('Under Construction')`
                                    when 'rename_item'
                                        page.open_dialog(the_application,{:type => :input, :title => 'Rename', :banner => 'Please provide a unique valid name:', :default => current_selection[:profile][:title]}) do |response|
                                            if response.is_a?(::Hash)
                                                unless response[:action] == :cancel
                                                    if response[:form][:data].to_s.size > 0
                                                        #
                                                        if response[:form][:data].to_s != current_selection[:profile][:title]
                                                            # Filter the name
                                                            the_filename = ''
                                                            response[:form][:data].to_s.chars.each do |the_char|
                                                                if the_char.match(/[a-zA-Z0-9\-\_\.]/)
                                                                    the_filename = (the_filename + the_char)
                                                                end
                                                            end
                                                            if File.extname(the_filename) == '' && File.extname(current_selection[:path].to_s) != ''
                                                                the_filename = (the_filename + File.extname(current_selection[:path].to_s) )
                                                            end
                                                            #
                                                            details = {:action => 'rename', :path => current_selection[:path].to_s, :new_name => the_filename}
                                                            error_handler = Proc.new { |response|
                                                                # communication errors only
                                                                log_warn(response.inspect)
                                                                page.set_busy(false)
                                                            }
                                                            page.set_busy(true)
                                                            GxG::CONNECTION.vfs(details,error_handler) do |response|
                                                                if response.is_a?(::Hash)
                                                                    # Update display
                                                                    parent_path = File.dirname(current_selection[:path].to_s)
                                                                    the_application.refresh_vfs_tree_profile(parent_path) do |result|
                                                                        if result
                                                                            list_view.update_appearance(tree_view.node_at_path(parent_path))
                                                                        end
                                                                    end
                                                                end
                                                                page.set_busy(false)
                                                            end
                                                            #
                                                        end
                                                        #
                                                    end
                                                end
                                            end
                                        end
                                    when 'copy_item'
                                        page.vfs_dialog(the_application, {:type => :folder, :path => File.dirname(current_selection[:path]), :disallow => File.basename(current_selection[:path])}) do |response|
                                            if response.is_a?(::Hash)
                                                unless response[:action] == :cancel
                                                    unless File.dirname(current_selection[:path]) == response[:path]
                                                        error_handler = Proc.new do |the_err|
                                                            log_error(the_err.inspect)
                                                            page.set_busy(false)
                                                        end
                                                        page.set_busy(true)
                                                        # Review : remake remote calls
                                                        # GxG::CONNECTION.action({:vfs_copy => {:source => ..., :destination => ...}})
                                                        GxG::CONNECTION.vfs({:action => 'copy', :source => current_selection[:path], :destination => (response[:path] + '/' + File.basename(current_selection[:path]))},error_handler) do |remote_response|
                                                            #
                                                            the_application.refresh_vfs_tree_profile(response[:path]) do |updated_profile|
                                                                dst_node = tree_view.node_at_path(response[:path])
                                                                if dst_node
                                                                    dst_node.data[:content] = (updated_profile[:content] ||  {})
                                                                end
                                                                page.set_busy(false)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    when 'move_item'
                                        page.vfs_dialog(the_application, {:type => :folder, :path => File.dirname(current_selection[:path]), :disallow => File.basename(current_selection[:path])}) do |response|
                                            if response.is_a?(::Hash)
                                                unless response[:action] == :cancel
                                                    unless File.dirname(current_selection[:path]) == response[:path]
                                                        error_handler = Proc.new do |the_err|
                                                            log_error(the_err.inspect)
                                                            page.set_busy(false)
                                                        end
                                                        page.set_busy(true)
                                                        GxG::CONNECTION.vfs({:action => 'move', :source => current_selection[:path], :destination => (response[:path] + '/' + File.basename(current_selection[:path]))},error_handler) do |remote_response|
                                                            # refresh display
                                                            the_application.refresh_vfs_tree_profile(File.dirname(current_selection[:path])) do |updated_profile_a|
                                                                the_application.refresh_vfs_tree_profile(response[:path]) do |updated_profile_b|
                                                                    src_node = tree_view.node_at_path(File.dirname(current_selection[:path]))
                                                                    if src_node
                                                                        src_node.data[:content] = (updated_profile_a[:content] ||  {})
                                                                        list_view.select_item(nil)
                                                                        list_view.update_appearance(src_node)
                                                                    end
                                                                    #
                                                                    dst_node = tree_view.node_at_path(response[:path])
                                                                    if dst_node
                                                                        dst_node.data[:content] = (updated_profile_b[:content] ||  {})
                                                                    end
                                                                    #
                                                                    the_details = the_window.find_child('details')
                                                                    if the_details
                                                                        the_details.update_appearance()
                                                                    end
                                                                    page.set_busy(false)
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    when 'permissions'
                                        # Gather group and role data
                                        page.set_busy(true)
                                        GxG::CONNECTION.admin({:action => 'get_groups'}) do |response|
                                            if response.is_a?(::Hash)
                                                if response[:result].is_a?(::Hash)
                                                    the_groups = response[:result]
                                                    GxG::CONNECTION.get_permissions(current_selection[:path]) do |other_response|
                                                        # retuns an array of permission provision records
                                                        # each permission in the_current_permissions: {:credential => '', :permissions => {}, :details => {:user_title => ''}}
                                                        the_current_permissions = other_response[:result]
                                                        page.set_busy(false)
                                                        the_dialog_source = the_application.search_content('permission_dialog')
                                                        if the_dialog_source
                                                            page.dialog_open(the_dialog_source,the_application,{:operation => record[:operation]}.merge!({:selection => current_selection, :groups => the_groups, :permissions => the_current_permissions})) do |reaction|
                                                                if reaction.is_a?(::Hash)
                                                                    unless reaction[:action] == :cancel
                                                                        error_handler = Proc.new { |error_response|
                                                                            log_error(error_response.inspect)
                                                                            GxG::DISPLAY_DETAILS[:object].set_busy(false)
                                                                        }
                                                                        GxG::DISPLAY_DETAILS[:object].set_busy(true)
                                                                        GxG::CONNECTION.vfs({:action => 'set_permissions', :path => current_selection[:path], :alterations => reaction[:alterations], :revocations => reaction[:revocations]},error_handler) do |final_response|
                                                                            # update permission info
                                                                            the_application.refresh_vfs_tree_profile(current_selection[:path]) do |the_profile|
                                                                                the_details = the_window.find_child('details')
                                                                                if the_details
                                                                                    the_details.update_appearance()
                                                                                end
                                                                                GxG::DISPLAY_DETAILS[:object].set_busy(false)
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        else
                                                            log_warn('Dialog Resource NOT found.')
                                                        end
                                                        #
                                                    end
                                                end
                                            end
                                        end
                                        # {:selection => current_selection, :groups => nil}
                                    when 'delete_item'
                                        page.open_dialog(the_application,{:type => :choose, :title => 'Delete', :banner => 'This will PERMANENTLY delete the item. Are you sure?', :one => 'Cancel', :two => 'Delete'}) do |response|
                                            if response.is_a?(::Hash)
                                                unless response[:action] == :one
                                                    if ['directory', 'virutal_directory', 'persisted_array'].include?(current_selection[:profile][:type].to_s)
                                                        vfs_op = 'rmdir'
                                                    else
                                                        vfs_op = 'rmfile'
                                                    end
                                                    # delete item:
                                                    if vfs_op && current_selection[:path]
                                                        details = {:action => vfs_op, :path => current_selection[:path].to_s}
                                                        error_handler = Proc.new { |response|
                                                            # communication errors only
                                                            log_warn(response.inspect)
                                                            self.page.set_busy(false)
                                                        }
                                                        self.page.set_busy(true)
                                                        GxG::CONNECTION.vfs(details,error_handler) do |response|
                                                            if response.is_a?(::Hash)
                                                                parent_path = File.dirname(current_selection[:path].to_s)
                                                                the_application.refresh_vfs_tree_profile(parent_path) do |result|
                                                                    if result
                                                                        list_view.update_appearance(tree_view.node_at_path(parent_path))
                                                                    end
                                                                end
                                                            end
                                                            self.page.set_busy(false)
                                                        end
                                                    end
                                                    #
                                                end
                                            end
                                        end
                                    else
                                        log_warn('Unknown Menu Item Operation: ' + record[:operation].to_s)
                                    end
                                end
                            end
                        else
                            log_warn('Application && Selection not present')
                        end
                    else
                        log_warn('Cannot locate local Window object')
                    end
                end
            end
            ".encode64
            #
            puts "Building Object Menu ..."
            persisted_object_menu_bar = GxG::DB[:roles][:software].try_persist(object_menu_bar, GxG::DB[:administrator])
            persisted_object_menu_bar.set_title("object_browser_menu")
            # ----------------------------------------------------------------------------------------
            #
            # Dialog Boxes:
            # ----------------------------------------------------------------------------------------
            # Permissions for Item:
            info_text = {:component=>"text", :options=> {:content => "Select a Group & Role to set its permissions:", :style => {:"font-size" => "16px"}}, :content => [], :script => ""}
            info_cell = {:component => "block_table_cell", :options => {:style => {:padding => "0px", :margin => "0px", :width => "80%"}}, :content => [(info_text)], :script => ""}
            # User / Role selector
            # {:icon => "<src>", :icon_width => 32, :icon_height => 32, :label => "", :uuid => "<uuid>"}
            # Window Data: {:selection => {:path => the_selection, :profile => the_profile}, :groups => the_groups, :permissions => the_current_permissions}
            # (GxG::CONNECTION.admin({:action => 'get_groups'}) ==> result:)
            # :groups => {"e2f929cf-dd1d-4666-aef4-9d4a4a232573"=>{"title"=>"Administrators", "seo"=>"administrators", "version"=>0, "groups"=>{}, "roles"=>{"4ccc35ee-ec35-407f-b784-ef3fed9a8254"=>{"title"=>"Members", "seo"=>"members", "version"=>0}}}, "4bd8fc7d-43e2-48bb-b8f3-6a68d33db998"=>{"title"=>"Developers", "seo"=>"developers", "version"=>0, "groups"=>{}, "roles"=>{"bceba8c3-3869-4d51-b382-f92adbd7cd5a"=>{"title"=>"Members", "seo"=>"members", "version"=>0}}}, "4db04677-f56e-4a39-a3d2-ec3ee9b1f2af"=>{"title"=>"Designers", "seo"=>"designers", "version"=>0, "groups"=>{}, "roles"=>{"1ac12587-f320-4e23-94ce-de6929ceb690"=>{"title"=>"Members", "seo"=>"members", "version"=>0}}}}
            # Group Record:
            # group: {:title => the_group[:title], :seo => the_group[:seo], :version => the_group[:version], :groups => {}, :roles => {}}
            # roles: {:title => the_role[:title], :seo => the_role[:seo], :version => the_role[:version]}
            # (GxG::CONNECTION.get_permissions(current_selection[:path]) ==> result:)
            # :permissions => [{"credential"=>"eb82b27a-02fe-47d7-9bf5-ca9c9de5bc62", "permissions"=>{"execute"=>false, "rename"=>true, "move"=>true, "destroy"=>true, "create"=>true, "write"=>true, "read"=>true}, "details"=>{"user_title"=>"root"}}, {"credential"=>"4ccc35ee-ec35-407f-b784-ef3fed9a8254", "permissions"=>{"execute"=>false, "rename"=>true, "move"=>true, "destroy"=>true, "create"=>true, "write"=>true, "read"=>true}, "details"=>{"role_title"=>"Members", "group"=>"e2f929cf-dd1d-4666-aef4-9d4a4a232573", "group_title"=>"Administrators"}}, {"credential"=>"00000000-0000-4000-0000-000000000000", "permissions"=>{"execute"=>true, "rename"=>false, "move"=>false, "destroy"=>false, "create"=>false, "write"=>false, "read"=>true}, "details"=>{"user_title"=>"public"}}]
            # Window Data:
            # {:selection => {:path => the_selection, :profile => the_profile}, :groups => the_groups, :permissions => the_current_permissions}
            #
            selector_list = {:component=>"list", :options=>{:title => "selector_list", :style => {:clear => "both", :"list-style" => "none", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            selector_list[:script] = "
            def update_appearance()
                # Lists all group >> role combinations & Public (available groups)
                the_window = self.find_parent_type(::GxG::Gui::DialogBox)
                if the_window
                    self.children.values.each do |the_item|
                        the_item.destroy
                    end
                    the_window.available().each_pair do |the_credential, the_record|
                        unless the_window.alterations().keys.include?(the_credential.to_s.to_sym)
                            self.add_list_item({:label => the_record[:title], :uuid => the_credential.to_s})
                        end
                    end
                end
                #
            end
            ".encode64
            selector_container = {:component=>"block", :options => {:style => {:width => "100%", :height => "100px", :"overflow-y" => "scroll", :border => "1px solid #c2c2c2"}}, :content => [(selector_list)], :script => ""}
            selector_cell = {:component => "block_table_cell", :options => {:style => {:padding => "0px", :margin => "0px", :width => "80%"}}, :content => [(selector_container)], :script => ""}
            # Include / Exclude User or Role:
            # includer_text = {:component=>"text", :options=> {:content => "Include", :style => {:"font-size" => "16px"}}, :content => [], :script => ""}
            includer = {:component=>"image", :options=>{:src=>"/themes/setup/widgets/expand_bottom.svg", :alt => "Include", :width=>64, :height=>32, :style => {:clear => "both", :border => "1px solid #c2c2c2"}}, :content=>[], :script=>""}
            includer[:script] = "
            on(:mousedown) do |event|
                self.gxg_merge_style({:'background-color' => '#87acd5'})
            end
            on(:mouseup) do |event|
                self.gxg_merge_style({:'background-color' => '#f2f2f2'})
                the_window = self.find_parent_type(::GxG::Gui::DialogBox)
                if the_window
                    selector = the_window.find_child('selector_list')
                    if selector
                        if selector.selection().to_s.size > 0
                            self.page.set_busy(true)
                            the_window.include_credential(selector.selection().to_s.to_sym)
                            self.page.set_busy(false)
                        end
                    end
                end
            end
            ".encode64
            #
            includer_cell = {:component => "block_table_cell", :options => {:style => {:padding => "5px 0px 5px 120px", :margin => "0px", :width => "50px"}}, :content => [(includer)], :script => ""}
            #
            # excluder_text = {:component=>"text", :options=> {:content => "Exclude", :style => {:"font-size" => "16px"}}, :content => [], :script => ""}
            excluder = {:component=>"image", :options=>{:src=>"/themes/setup/widgets/expand_top.svg", :alt => "Exclude", :width=>64, :height=>32, :style => {:clear => "both", :border => "1px solid #c2c2c2"}}, :content=>[], :script=>""}
            excluder[:script] = "
            on(:mousedown) do |event|
                self.gxg_merge_style({:'background-color' => '#87acd5'})
            end
            on(:mouseup) do |event|
                self.gxg_merge_style({:'background-color' => '#f2f2f2'})
                the_window = self.find_parent_type(::GxG::Gui::DialogBox)
                if the_window
                    selector = the_window.find_child('display_list')
                    if selector
                        if selector.selection().to_s.size > 0
                            self.page.set_busy(true)
                            the_window.exclude_credential(selector.selection().to_s.to_sym)
                            self.page.set_busy(false)
                        end
                    end
                end
            end
            ".encode64
            #
            excluder_cell = {:component => "block_table_cell", :options => {:style => {:padding => "0px", :margin => "0px", :width => "50px"}}, :content => [(excluder)], :script => ""}
            # Permission display
            display = {:component=>"list", :options=>{:title => "display_list", :style => {:clear => "both", :"list-style" => "none", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            display[:script] = "
            def permission_components(credential=nil, permission_set={})
                # produce a single line item with a name, uuid, and permission check boxes.
                build_list = []
                #
                if permission_set.is_any?(::Hash, ::GxG::Database::PersistedHash)
                    component_script = '
                        on(:mouseup) do |event|
                            the_window = self.find_parent_type(::GxG::Gui::DialogBox)
                            if the_window
                                GxG::DISPATCHER.post_event(:root) do
                                    the_window.set_permission({:credential => self.gxg_get_attribute(:credential).to_s.to_sym, :permission => self.gxg_get_attribute(:permission).to_s.downcase.to_sym, :state => self.is_set?()})
                                end
                            end
                        end
                    '
                    permission_set.each_pair do |name, state|
                        if state == true
                            build_list << {:component => 'checkbox', :options => {:name => 'permission', :permission => name.to_s, :checked => nil, :credential => credential.to_s}, :content => [], :script => component_script}
                            #
                        else
                            build_list << {:component => 'checkbox', :options => {:name => 'permission', :permission => name.to_s, :credential => credential.to_s}, :content => [], :script => component_script}
                            #
                        end
                        build_list << {:component=>'text', :options=> {:content => name.to_s.capitalize, :style => {:'font-size' => '12px'}}, :content => [], :script => ''}
                        #
                    end
                end
                #
                build_list
            end
            def update_appearance()
                # Lists allocated (groups >> role combinations) / Public
                the_window = self.find_parent_type(::GxG::Gui::DialogBox)
                if the_window
                    self.children.values.each do |the_item|
                        the_item.destroy
                    end
                    the_window.alterations().each_pair do |the_credential, the_record|
                        #
                        self.add_list_item({:label => the_record[:title], :uuid => the_credential.to_s, :label_cell_style => {:padding => '0px', :width => '250px'}, :content => self.permission_components(the_credential, the_record[:permissions])})
                        #
                    end
                end
                #
            end
            ".encode64
            display_container = {:component=>"block", :options => {:style => {:width => "100%", :height => "100px", :"overflow-y" => "scroll", :border => "1px solid #c2c2c2"}}, :content => [(display)], :script => ""}
            display_cell = {:component => "block_table_cell", :options => {:style => {:padding => "0px", :margin => "0px", :width => "80%"}}, :content => [(display_container)], :script => ""}
            # Save Button
            submit_btn = {:component=>"submit_button", :options=>{:title => "save_button", :content => "Save", :style => {:padding => "2px", :width => "80px", :height => "32px"}}, :content=>[], :script=>""}
            submit_btn[:script] = "
            on(:mouseup) do |event|
                the_window = self.find_parent_type(::GxG::Gui::DialogBox)
                form = self.find_parent_type(:form)
                if the_window && form
                    # path & profile:
                    current = the_window.data()
                    #
                    # {:title => the_group[:title], :seo => the_group[:seo], :version => the_group[:version], :groups => {}, :roles => {}}
                    # roles: {:title => the_role[:title], :seo => the_role[:seo], :version => the_role[:version]}
                    #
                    if current.is_any?(::Hash, ::GxG::Database::PersistedHash)
                        if current.size > 0
                            the_alterations = []
                            #
                            the_window.alterations().each_pair do |the_credential, the_record|
                                the_alterations << {:credential => the_credential, :permissions => the_record[:permissions]}
                            end
                            the_window.respond({:action => :save, :alterations => the_alterations, :revocations => the_window.revocations()})
                        else
                            log_warn('No data provided for the DialogBox to work with. See: GxG::Gui::DialogBox.set_data')
                            the_window.respond({:action => :cancel})
                        end
                    else
                        log_warn('BAD data (should be a Hash/PersistedHash) provided for the DialogBox to work with. See: GxG::Gui::DialogBox.set_data')
                        the_window.respond({:action => :cancel})
                    end
                end
            end
            ".encode64
            submit_cell = {:component => "block_table_cell", :options => {:style => {:padding => "10px 0px 0px 135px", :margin => "0px", :width => "80px"}}, :content => [(submit_btn)], :script => ""}
            cancel_btn = {:component=>"button", :options=>{:content => "Cancel", :style => {:padding => "2px", :width => "80px", :height => "32px"}}, :content=>[], :script=>""}
            cancel_btn[:script] = "
            on(:mouseup) do |event|
                the_window = self.find_parent_type(::GxG::Gui::DialogBox)
                if the_window
                    the_window.respond({:action => :cancel})
                end
            end
            ".encode64
            cancel_cell = {:component => "block_table_cell", :options => {:style => {:padding => "10px 0px 0px 135px", :margin => "0px", :width => "80px"}}, :content => [(cancel_btn)], :script => ""}
            # Dialog Structure:
            ni_row_one = {:component=>"block_table_row", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[(info_cell)], :script=>""}
            ni_row_two = {:component=>"block_table_row", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[(selector_cell)], :script=>""}
            ni_row_three = {:component=>"block_table_row", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[(includer_cell),(excluder_cell)], :script=>""}
            ni_row_four = {:component=>"block_table_row", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[(display_cell)], :script=>""}
            ni_row_five = {:component=>"block_table_row", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[(cancel_cell),(submit_cell)], :script=>""}
            # 
            ni_table_one = {:component=>"block_table", :options=>{:style => {:padding => "0px", :margin => "0px", :width => "100%", :height => 24}}, :content=>[(ni_row_one)], :script=>""}
            # 
            ni_table_two = {:component=>"block_table", :options=>{:style => {:padding => "0px", :margin => "0px", :width => "100%", :height => 96}}, :content=>[(ni_row_two)], :script=>""}
            ni_table_three = {:component=>"block_table", :options=>{:style => {:padding => "0px", :margin => "0px", :width => "100%", :height => 42}}, :content=>[(ni_row_three)], :script=>""}
            ni_table_four = {:component=>"block_table", :options=>{:style => {:padding => "0px", :margin => "0px", :width => "100%", :height => 96}}, :content=>[(ni_row_four)], :script=>""}
            ni_table_five = {:component=>"block_table", :options=>{:style => {:padding => "0px", :margin => "0px", :width => "100%", :height => 32}}, :content=>[(ni_row_five)], :script=>""}
            # form height +50px
            ni_form = {:component=>"form", :options=>{:style => {:"background-color" => "#f2f2f2", :padding => "0px 20px 20px 20px", :margin => "5px", :width => "700px"}}, :content=>[(ni_table_one),(ni_table_two),(ni_table_three),(ni_table_four),(ni_table_five)], :script=>""}
            ni_viewport = {:component=>"application_viewport", :options=>{:title => "permissions_viewport", :style => {:overflow => "hidden", :width => "100%", :height => "100%"}}, :content=>[(ni_form)], :script=>""}
            permissions_item_dialog = {:component => "dialog_box", :options => {:window_title => "Set Permissions:", :states => {:hidden => true}, :width => 700, :height => 360}, :script => "", :content => [(ni_viewport)]}
            permissions_item_dialog[:script] = "
            def before_open(data=nil)
                @available = {}
                @alterations = {}
                @revocations = []
                # Populate instance vars from available data
                (self.data() || {:groups => {}})[:groups].search do |value, selector, container|
                    if selector == :roles
                        value.each_pair do |the_credential, role_detail|
                            @available[(the_credential.to_s.to_sym)] = {:title => (container[:title] + ' >> ' + role_detail[:title])}
                        end
                    end
                end
                unless @available.keys.include?(:'00000000-0000-4000-0000-000000000000')
                    @available[:'00000000-0000-4000-0000-000000000000'] = {:title => 'Public'}
                end
                #
                # self.data()[:permissions][(indexer)] ==> {:credential => '', :permissions => {}, :details => {:user_title => ''}}
                (self.data() || {:permissions => []})[:permissions].each do |the_record|
                    if @available.keys.include?(the_record[:credential].to_s.to_sym)
                        @alterations[(the_record[:credential].to_s.to_sym)] = {:title => (@available[(the_record[:credential].to_s.to_sym)][:title]), :permissions => the_record[:permissions]}
                        # Prune allocated credentials from @available (this effectively MOVES the entry to)
                        @available.delete(the_record[:credential].to_s.to_sym)
                    end
                end
                true
                #
            end
            #
            def set_permission(details={})
                if @alterations.keys.include?(details[:credential].to_s.to_sym)
                    @alterations[(details[:credential].to_s.to_sym)][:permissions][(details[:permission].to_s.downcase.to_sym)] = details[:state]
                else
                    new_permission = {:execute => false, :rename => false, :move => false, :destroy => false, :create => false, :write => false, :read=>true}
                    new_permission[(details[:permission].to_s.to_sym)] = details[:state]
                    found_title = 'Unknown'
                    @available.each_pair do |the_credential, the_record|
                        if the_credential == details[:credential].to_s.to_sym
                            found_title = the_record[:title]
                            break
                        end
                    end
                    @alterations[(details[:credential].to_s.to_sym)] = {:title => found_title, :permissions => new_permission}
                end
                # DEBUG:
                # log_info(@alterations[(details[:credential].to_s.to_sym)].inspect)
            end
            #
            def include_credential(the_credential=nil)
                # remove from @revocations if present
                if @revocations.include?(the_credential.to_s.to_sym)
                    @revocations.delete_at(@revocations.find_index(the_credential.to_s.to_sym))
                end
                # add to display
                self.set_permission({:credential => the_credential.to_s.to_sym, :permission => :read, :state => true})
                # remove from selector_list
                @available.delete(the_credential.to_s.to_sym)
                # update displays
                selector = self.find_child('selector_list')
                if selector
                    selector.update_appearance()
                end
                display = self.find_child('display_list')
                if display
                    display.update_appearance()
                end
                true
            end
            #
            def exclude_credential(the_credential=nil)
                # remove from display
                if @alterations.keys.include?(the_credential.to_s.to_sym)
                    title = @alterations.delete(the_credential.to_s.to_sym)[:title]
                else
                    title = 'Unknown'
                end
                # add to selector_list
                @available[(the_credential.to_s.to_sym)] = {:title => title}
                # add to @revocations
                unless @revocations.include?(the_credential.to_s.to_sym)
                    @revocations << the_credential.to_s.to_sym
                end
                selector = self.find_child('selector_list')
                if selector
                    selector.update_appearance()
                end
                display = self.find_child('display_list')
                if display
                    display.update_appearance()
                end
                true
            end
            #
            def available()
                @available || {}
            end
            #
            def alterations()
                @alterations || {}
            end
            #
            def revocations()
                @revocations || []
            end
            #
            def open(data=nil)
                selector = self.find_child('selector_list')
                if selector
                    selector.update_appearance()
                end
                display = self.find_child('display_list')
                if display
                    display.update_appearance()
                end
            end
            #
            ".encode64
            #
            puts "Building Permissions Dialog ..."
            persisted_permissions_item_dialog = GxG::DB[:roles][:software].try_persist(permissions_item_dialog, GxG::DB[:administrator])
            persisted_permissions_item_dialog.set_title("permission_dialog")
            # ----------------------------------------------------------------------------------------
            if GxG::VFS.exist?("/Public/www/software/applications/object_browser")
                GxG::VFS.rmfile("/Public/www/software/applications/object_browser")
            end
            new_app = GxG::VFS.mkfile("/Public/www/software/applications/object_browser")
            new_app.get_reservation
            puts "Setting up Object Browser Application ..."
            app.keys.each do |the_key|
                new_app[(the_key)] = app[(the_key)]
            end
            new_app[:content] << persisted_window
            new_app[:content] << persisted_object_menu_bar
            new_app[:content] << persisted_permissions_item_dialog
            puts "Setting public permissions ..."
            new_app.set_permissions(:"00000000-0000-4000-0000-000000000000", {:execute => true, :read => true})
            new_app.deactivate
            true
        end
        #
        def self.setup_switcher_app()
            app = {:component => "application", :requirements => [], :options=>{:credentialed=>false, :unique=>true, :category => "System"}, :script=>"", :content=>[]}
            app[:script] = "
            def activate_window(details)
                the_window = GxG::DISPLAY_DETAILS[:object].get_window(details[:reference])
                if the_window
                    if the_window.special_state()
                        unless (the_window.special_state() || {})[:action] == :maximize
                            GxG::DISPLAY_DETAILS[:object].window_restore(details[:reference])
                        end
                    end
                end
                unless GxG::DISPLAY_DETAILS[:object].window_is_in_front?(details[:reference])
                    GxG::DISPLAY_DETAILS[:object].window_bring_to_front(details[:reference])
                end
            end
            def generate_menu_components()
                # Dynamically generate viewport component build-list (Array).
                logged_in = GxG::DISPLAY_DETAILS[:logged_in]
                result = {:component=>'list', :options=>{:style => {:padding => '0px', :margin => '0px'}}, :content=>[], :script=>''}
                result[:script] = \"
                on(:mouseleave) do |event|
                    viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('switcher_menu')
                    if viewport
                        viewport.application.toggle_menu
                    end
                end
                \".encode64
                windows = GxG::DISPLAY_DETAILS[:object].window_list()
                if windows.is_a?(::Array)
                    windows.each do |record|
                        #
                        item_block = {:component=>'list_item', :options=>{:style => {:padding => '0px', :margin => '0px', :'background-color' => '#f2f2f2'}}, :content=>[], :script=>''}
                        #
                        if item_block
                            item_block[:options][:reference] = record[:uuid].to_s
                            #
                            item_block[:options][:unique] = record[:unique]
                            table = {:component=>'table', :options=>{:style => {:padding => '0px', :margin => '0px', :'background-color' => 'transparent'}}, :content=>[], :script=>''}
                            row = {:component=>'table_row', :options=>{:style => {:padding => '0px', :margin => '0px', :'background-color' => 'transparent'}}, :content=>[], :script=>''}
                            cell_one = {:component=>'table_cell', :options=>{:style => {:padding => '2px', :margin => '0px', :'background-color' => 'transparent'}}, :content=>[], :script=>''}
                            #
                            window_object = GxG::DISPLAY_DETAILS[:object].get_window(record[:uuid])
                            if window_object
                                window_title = window_object.window_title()
                            else
                                window_title = 'Untitled Object'
                            end
                            window_name = {:component=>'label', :options=>{:content => window_title.to_s, :style => {:'font-size' => '16px'}}, :content=>[], :script=>''}
                            #
                            cell_one[:content] << window_name
                            row[:content] << cell_one
                            table[:content] << row
                            item_block[:content] << table
                            item_block[:script] = \"
                            on(:mouseenter) do |event|
                                self.gxg_merge_style({:'background-color' => '#87acd5'})
                            end
                            on(:mouseleave) do |event|
                                self.gxg_merge_style({:'background-color' => '#f2f2f2'})
                            end
                            on(:mouseup) do |event|
                                viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('switcher_menu')
                                if viewport
                                    viewport.application.toggle_menu
                                    viewport.application.activate_window({:reference => self.gxg_get_attribute(:reference)})
                                end
                            end
                            \".encode64
                        end
                        if item_block
                            result[:content] << item_block
                        end
                    end
                end
                result
            end
            def toggle_menu()
                viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('switcher_menu')
                if viewport
                    if viewport.gxg_get_state(:hidden) == true
                        self.viewport_build(viewport.uuid, self.generate_menu_components())
                        viewport.show({:origin => {:opacity => 0}, :destination => {:opacity => 1}})
                    else
                        viewport.hide({:origin => {:opacity => 1}, :destination => {:opacity => 0}}) do
                            self.viewport_clear(viewport.uuid)
                        end
                    end
                end
            end
            def run(details={})
                viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('switcher_menu')
                if viewport
                    GxG::DISPLAY_DETAILS[:object].set_window_switcher(viewport)
                end
            end
            ".encode64
            # requirement format: {:library => "", :type => "", :minimum => 0.0, :maximum => nil}
            nativelib = {
            	:component=>"library",
            	:type => "text/javascript",
            	:requirements => [],
            	:options=>{
            			:src => "javascript/ace/ace.js",
            			:global => "ace"
            			},
            	:content=>[],
            	:script=>""
            	}
            # persisted_nativelib = GxG::DB[:roles][:software].try_persist(nativelib, GxG::DB[:administrator])
            # persisted_nativelib.set_title("ace")
            #
            if GxG::VFS.exist?("/Public/www/software/applications/switcher")
                GxG::VFS.rmfile("/Public/www/software/applications/switcher")
            end
            new_app = GxG::VFS.mkfile("/Public/www/software/applications/switcher")
            new_app.get_reservation
            puts "Setting up Window Switcher Application..."
            app.keys.each do |the_key|
                new_app[(the_key)] = app[(the_key)]
            end
            # new_app[:content] << persisted_nativelib
            puts "Setting public permissions ..."
            new_app.set_permissions(:"00000000-0000-4000-0000-000000000000", {:execute => true, :read => true})
            new_app.deactivate
            true
        end
        #
        def self.setup_menu_app()
            app = {:component => "application", :requirements => [], :options=>{:credentialed=>false, :unique=>true, :category => "System"}, :script=>"", :content=>[]}
            app[:script] = "
            def open_application(the_settings=nil)
                if the_settings.is_a?(::Hash)
                    location = the_settings[:location].to_s
                    # FIXME: might not need to pass unique flag at all -- reconsider inclusion in the_settings.
                    if the_settings[:unique] == 'true' || the_settings[:unique] == true
                        unique = true
                    else
                        unique = false
                    end
                    found = nil
                    GxG::APPLICATIONS[:processes].values.each do |the_process|
                        if the_process.location == location
                            if the_process.unique == true
                                found = the_process
                                # Switch window focus (if window) to already running application ??
                                break
                            end
                        end
                    end
                    unless found
                        the_app = GxG::DISPLAY_DETAILS[:object].application_open({:location => location})
                        if the_app
                            the_app.run()
                        end
                    end
                end
            end
            def generate_menu_components()
                # Dynamically generate viewport component build-list (Array) based upon @heap data.
                logged_in = GxG::DISPLAY_DETAILS[:logged_in]
                result = {:component=>'list', :options=>{:style => {:padding => '0px', :margin => '0px'}}, :content=>[], :script=>''}
                result[:script] = \"
                on(:mouseleave) do |event|
                    viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('menu')
                    if viewport
                        viewport.application.toggle_menu
                    end
                end
                \".encode64
                if @heap[:menu_data].is_a?(::Array)
                    @heap[:menu_data].each do |record|
                        # {:location => '', :application_icon_type => '', :application_icon => '', :application_name => '', :credentialed => false, :unique => true, :category => ''}
                        item_block = nil
                        if record[:credentialed] == true
                            if logged_in == true
                                item_block = {:component=>'list_item', :options=>{:style => {:padding => '0px', :margin => '0px', :'background-color' => '#f2f2f2'}}, :content=>[], :script=>''}
                            end
                        else
                            item_block = {:component=>'list_item', :options=>{:style => {:padding => '0px', :margin => '0px', :'background-color' => '#f2f2f2'}}, :content=>[], :script=>''}
                        end
                        if item_block
                            item_block[:options][:thepath] = record[:location].to_s
                            item_block[:options][:unique] = record[:unique]
                            table = {:component=>'table', :options=>{:style => {:padding => '0px', :margin => '0px', :'background-color' => 'transparent'}}, :content=>[], :script=>''}
                            row = {:component=>'table_row', :options=>{:style => {:padding => '0px', :margin => '0px', :'background-color' => 'transparent'}}, :content=>[], :script=>''}
                            cell_one = {:component=>'table_cell', :options=>{:style => {:padding => '2px', :margin => '0px', :'background-color' => 'transparent'}}, :content=>[], :script=>''}
                            cell_two = {:component=>'table_cell', :options=>{:style => {:padding => '2px', :margin => '0px', :'background-color' => 'transparent', :'vertical-align' => 'middle'}}, :content=>[], :script=>''}
                            if record[:application_icon].base64? && record[:application_icon_type].to_s.size > 0
                                src = ('data:' + record[:application_icon_type].to_s + ';base64,' + record[:application_icon].to_s)
                            else
                                src = record[:application_icon].to_s
                            end
                            app_icon = {:component=>'image', :options=>{:src=> src, :width=>32, :height=>32}, :content=>[], :script=>''}
                            app_name = {:component=>'label', :options=>{:content => record[:application_name].to_s, :style => {:'font-size' => '16px'}}, :content=>[], :script=>''}
                            app_location = record[:location].to_s
                            # Ignore category for now (need tree component first)
                            app_category = record[:category].to_s
                            #
                            cell_one[:content] << app_icon
                            cell_two[:content] << app_name
                            row[:content] << cell_one
                            row[:content] << cell_two
                            table[:content] << row
                            item_block[:content] << table
                            item_block[:script] = \"
                            on(:mouseenter) do |event|
                                self.gxg_merge_style({:'background-color' => '#87acd5'})
                            end
                            on(:mouseleave) do |event|
                                self.gxg_merge_style({:'background-color' => '#f2f2f2'})
                            end
                            on(:mouseup) do |event|
                                viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('menu')
                                if viewport
                                    the_specifier = {:location => self.gxg_get_attribute(:thepath), :unique => self.gxg_get_attribute(:unique)}
                                    #
                                    viewport.application.toggle_menu
                                    viewport.application.open_application(the_specifier)
                                end
                            end
                            \".encode64
                        end
                        if item_block
                            result[:content] << item_block
                        end
                    end
                end
                result
            end
            def refresh_menu()
                # Load application_menu from server into @heap
                retry_fetch = Proc.new do |response|
                    GxG::CONNECTION.application_menu() do |response|
                        @heap[:menu_data] = response[:result]
                    end
                end
                GxG::CONNECTION.application_menu(retry_fetch) do |response|
                    @heap[:menu_data] = response[:result]
                end
                true
            end
            def toggle_menu()
                viewport = self.get_viewport('menu')
                if viewport
                    if viewport.gxg_get_state(:hidden) == true
                        # self.refresh_menu
                        self.viewport_build(viewport.uuid, self.generate_menu_components())
                        viewport.show({:origin => {:opacity => 0}, :destination => {:opacity => 1}})
                    else
                        viewport.hide({:origin => {:opacity => 1}, :destination => {:opacity => 0}}) do
                            self.viewport_clear(viewport.uuid)
                        end
                    end
                end
            end
            def run(settings={})
                self.refresh_menu
            end
            ".encode64
            #
            if GxG::VFS.exist?("/Public/www/software/applications/menu")
                GxG::VFS.rmfile("/Public/www/software/applications/menu")
            end
            new_app = GxG::VFS.mkfile("/Public/www/software/applications/menu")
            new_app.get_reservation
            puts "Setting up Application Menu ..."
            app.keys.each do |the_key|
                new_app[(the_key)] = app[(the_key)]
            end
            # Gather up components
            #
            puts "Setting public permissions ..."
            new_app.set_permissions(:"00000000-0000-4000-0000-000000000000", {:execute => true, :read => true})
            new_app.deactivate
            true
        end
        #
        def self.setup_login_app()
            app = {:component => "application", :requirements => [], :options=>{:credentialed=>false, :unique=>true, :category => "System"}, :script=>"", :content=>[]}
            app[:script] = "
            def show_login()
                viewport = self.get_viewport('login_viewport')
                if viewport
                    viewport.gxg_each_child do |the_child|
                        the_child.hide({:origin => {:opacity => 1}, :destination => {:opacity => 0}}) do
                            self.viewport_clear(viewport.uuid)
                            resource = self.search_content('login_form')
                            if resource
                                self.viewport_build(viewport.uuid,resource)
                            end
                            if viewport
                                viewport.gxg_every_child do |the_child|
                                    the_child.show({:origin => {:opacity => 0}, :destination => {:opacity => 1}})
                                end
                            end
                        end
                    end
                end
                true
            end
            def show_logout()
                viewport = self.get_viewport('login_viewport')
                if viewport
                    viewport.gxg_each_child do |the_child|
                        the_child.hide({:origin => {:opacity => 1}, :destination => {:opacity => 0}}) do
                            self.viewport_clear(viewport.uuid)
                            resource = self.search_content('logout_button')
                            if resource
                                self.viewport_build(viewport.uuid, resource)
                            end
                            if viewport
                                viewport.gxg_every_child do |the_child|
                                    the_child.show({:origin => {:opacity => 0}, :destination => {:opacity => 1}})
                                end
                            end
                        end
                    end
                end
                true
            end
            def run(settings={})
                # viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('login_viewport')
                viewport = self.get_viewport('login_viewport')
                if viewport
                    self.viewport_clear(viewport.uuid)
                    if GxG::DISPLAY_DETAILS[:logged_in] == true
                        resource = self.search_content('logout_button')
                    else
                        resource = self.search_content('login_form')
                    end
                    if resource
                        self.viewport_build(viewport.uuid, resource)
                    else
                        log_warn('error - internal resource not found ...')
                    end
                    viewport.gxg_every_child do |the_child|
                        the_child.show({:origin => {:opacity => 0}, :destination => {:opacity => 1}})
                    end
                    true
                else
                    log_warn('viewport not found ...')
                    false
                end
            end
            ".encode64
            #
            logout_btn = {:component=>"button", :options=>{:content => "Logout", :style => {:padding => "2px", :height => 32}, :states => {:hidden => true}}, :content=>[], :script=>""}
            logout_btn[:script] = "
            on(:mouseup) do |event|
                the_viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('login_viewport')
                if the_viewport
                    GxG::CONNECTION.downgrade_credential() do |response|
                        if response.is_a?(::Hash)
                            if response[:status] == 'uncredentialed'
                                the_app = the_viewport.application()
                                if the_app
                                    GxG::DISPLAY_DETAILS[:logged_in] = false
                                    the_app.show_login
                                end
                            end
                        end
                    end
                end
            end
            ".encode64
            persisted_logout_btn = GxG::DB[:roles][:software].try_persist(logout_btn, GxG::DB[:administrator])
            persisted_logout_btn.set_title("logout_button")
            #
            userlabel = {:component=>"label", :options=>{:content => "User:", :style => {:"font-size" => "12px"}, :states => {:hidden => true}}, :content=>[], :script=>""}
            userinput = {:component=>"text_input", :options=>{:style => {:"background-color" => "#f2f2f2", :"font-size" => "12px"}, :states => {:hidden => true}}, :content=>[], :script=>""}
            persisted_userinput = GxG::DB[:roles][:software].try_persist(userinput, GxG::DB[:administrator])
            persisted_userinput.set_title("userid")
            passlabel = {:component=>"label", :options=>{:content => "Password:", :style => {:"font-size" => "12px"}, :states => {:hidden => true}}, :content=>[], :script=>""}
            passinput = {:component=>"password_input", :options=>{:style => {:"background-color" => "#f2f2f2", :"font-size" => "12px"}, :states => {:hidden => true}}, :content=>[], :script=>""}
            passinput[:script] = "
            on(:keyup) do |event|
                if event[:which] == 13 || event[:key] == 'Enter' || event[:keyCode] == 13
                    the_viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('login_viewport')
                    if the_viewport
                        userinput = the_viewport.find_child('userid')
                        if userinput
                            user_id = userinput.value
                        else
                            user_id = nil
                        end
                        password = self.value
                        if user_id.to_s.size > 0 && password.to_s.size > 0
                            GxG::CONNECTION.update_credential({:user => user_id, :password => password}) do |response|
                                if response.is_a?(::Hash)
                                    if response[:status] == 'credentialed'
                                        the_app = the_viewport.application()
                                        if the_app
                                            GxG::DISPLAY_DETAILS[:logged_in] = true
                                            the_app.show_logout
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            ".encode64
            persisted_passinput = GxG::DB[:roles][:software].try_persist(passinput, GxG::DB[:administrator])
            persisted_passinput.set_title("password")
            btn = {:component=>"submit_button", :options=>{:content => "Login", :style => {:padding => "2px", :height => 32}, :states => {:hidden => true}}, :content=>[], :script=>""}
            btn[:script] = "
            on(:mouseup) do |event|
                the_viewport = self.viewport()
                if the_viewport
                    userinput = the_viewport.find_child('userid')
                    if userinput
                        user_id = userinput.value
                    else
                        user_id = nil
                    end
                    passinput = the_viewport.find_child('password')
                    if passinput
                        password = passinput.value
                    else
                        password = nil
                    end
                    if user_id.to_s.size > 0 && password.to_s.size > 0
                        GxG::CONNECTION.update_credential({:user => user_id, :password => password}) do |response|
                            if response.is_a?(::Hash)
                                if response[:status] == 'credentialed'
                                    the_app = the_viewport.application()
                                    if the_app
                                        GxG::DISPLAY_DETAILS[:logged_in] = true
                                        the_app.show_logout
                                    end
                                end
                            end
                        end
                    end
                end
            end
            ".encode64
            form_table = {:component=>"block_table", :options=>{:style => {:float => "right", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            form_row = {:component=>"block_table_row", :options=>{:style => {:clear => "both", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            form_cell_one = {:component=>"block_table_cell", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            form_cell_two = {:component=>"block_table_cell", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            form_cell_three = {:component=>"block_table_cell", :options=>{:style => {:padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            form = {:component=>"form", :options=>{:style => {:float => "right", :"background-color" => "#f2f2f2", :padding => "0px", :margin => "0px"}}, :content=>[], :script=>""}
            # link pieces
            form_cell_one[:content] = [(userlabel), nil]
            form_cell_two[:content] = [(passlabel), nil]
            form_cell_three[:content] = [(btn)]
            form_row[:content] = [(form_cell_one), (form_cell_two), (form_cell_three)]
            form_table[:content] = [(form_row)]
            form[:content] = [(form_table)]
            #
            persisted_form = GxG::DB[:roles][:software].try_persist(form, GxG::DB[:administrator])
            persisted_form.set_title("login_form")
            persisted_form[:content][0][:content][0][:content][0][:content][1] = persisted_userinput
            persisted_form[:content][0][:content][0][:content][1][:content][1] = persisted_passinput
            #
            if GxG::VFS.exist?("/Public/www/software/applications/login")
                GxG::VFS.rmfile("/Public/www/software/applications/login")
            end
            new_app = GxG::VFS.mkfile("/Public/www/software/applications/login")
            new_app.get_reservation
            puts "Setting up Login Application ..."
            app.keys.each do |the_key|
                new_app[(the_key)] = app[(the_key)]
            end
            new_app[:content] << persisted_form
            new_app[:content] << persisted_logout_btn
            puts "Setting public permissions ..."
            new_app.set_permissions(:"00000000-0000-4000-0000-000000000000", {:execute => true, :read => true})
            new_app.deactivate
            true
        end
        #
        def self.setup_index_page()
            # page = {:component => "page", :requirements => [], :page_title => "Under Construction", :accesskey => "", :class => "page", :contenteditable => false, :data => {}, :dir => "ltr",
            # :draggable => false, :dropzone => "", :id => "", :lang => "en", :spellcheck => false, :style => {}, :tabindex => 0,
            # :translate => "no", :content => [], :script => "", :theme => "default", :auto_start => []}
            page = {
                :component => "page",
                :requirements => [],
                :auto_start => [],
                :settings => {:page_title => "Under Construction", :theme => "default", :accesskey => "", :contenteditable => false, :dir => "ltr", :draggable => false, :dropzone => "", :lang => "en", :spellcheck => false, :translate => "no"},
                :options => {:style => {}, :states => ["page"], :tabindex => 0},
                :script => "",
                :content => []
            }
            #
            # Add stuff here
            #
            if GxG::VFS.exist?("/Public/www/content/pages/index")
                GxG::VFS.rmfile("/Public/www/content/pages/index")
            end
            #
            new_page = GxG::VFS.mkfile("/Public/www/content/pages/index")
            new_page.get_reservation
            puts "Setting up Default INDEX Page ..."
            page.keys.each do |the_key|
                new_page[(the_key)] = page[(the_key)]
            end
            # Gather up stray components
            #
            puts "Setting public permissions ..."
            new_page.set_permissions(:"00000000-0000-4000-0000-000000000000", {:read => true})
            new_page.deactivate
            true
        end
        #
        def self.setup_setup_page()
            # page = {:component => "page", :requirements => [], :page_title => "Welcome", :accesskey => "", :class => "page", :contenteditable => false, :data => {}, :dir => "ltr",
            #  :draggable => false, :dropzone => "", :id => "", :lang => "en", :spellcheck => false, :style => {}, :tabindex => 0,
            #  :translate => "no", :content => [], :script => "", :theme => "setup", :auto_start => [{:name => "switcher"}]}
             page = {
                 :component => "page",
                 :requirements => [],
                 :auto_start => [{:name => "switcher"}],
                 :settings => {:page_title => "Welcome", :theme => "default", :accesskey => "", :contenteditable => false, :dir => "ltr", :draggable => false, :dropzone => "", :lang => "en", :spellcheck => false, :translate => "no"},
                 :options => {:style => {}, :states => ["page"], :tabindex => 0},
                 :script => "",
                 :content => []
             }
            # page[:script] = "
            # ".encode64
            #
            menubar = {:component=>"panel", :options=>{:zone => "top",:top=>0, :left=>0, :style => {:width => "100%", :top => "0px", :left => "0px", :right => "0px", :height => "36px", :overflow => "hidden", :position => "absolute", :"text-align" => "left", :"border-radius" => "5px 5px 5px 5px"}, :states => {:"default-background-color" => true}}, :content=>[], :script=>""}
            table = {:component=>"block_table", :options=>{:style => {:"text-align" => "left", :width => "100%"}}, :content=>[], :script=>""}
            row = {:component=>"block_table_row", :options=>{:style => {:"vertical-align" => "middle"}}, :content=>[], :script=>""}
            image = {:component=>"image", :options=>{:src=>"/themes/setup/icons/gxg.png", :width=>32, :height=>32, :style => {:clear => "both"}}, :content=>[], :script=>""}
            image[:script] = "
            on(:mouseup) do |event|
                viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('menu')
                if viewport.is_a?(::GxG::Gui::ApplicationViewport)
                    viewport.application.toggle_menu()
                end
            end
            ".encode64
            switcher_image = {:component=>"image", :options=>{:src=>"/themes/setup/icons/switcher.png", :width=>32, :height=>32, :style => {:clear => "both"}}, :content=>[], :script=>""}
            switcher_image[:script] = "
            on(:mouseup) do |event|
                if GxG::DISPLAY_DETAILS[:object].window_list().size > 0
                    viewport = GxG::DISPLAY_DETAILS[:object].find_object_by_title('switcher_menu')
                    if viewport.is_a?(::GxG::Gui::ApplicationViewport)
                        viewport.application.toggle_menu()
                    end
                end
            end
            ".encode64
            #
            celltemplate = {:component=>"block_table_cell", :options=>{}, :content=>[], :script=>""}
            cellone = {:component=>"block_table_cell", :options=>{:style => {:width => 32, :float => "left", :"vertical-align" => "middle", :padding => "2px"}}, :content=>[], :script=>""}
            celltwo = {:component=>"block_table_cell", :options=>{:style => {:"vertical-align" => "middle", :padding => "2px"}}, :content=>[], :script=>""}
            cellthree = {:component=>"block_table_cell", :options=>{:style => {:float => "right", :"vertical-align" => "middle", :padding => "2px"}}, :content=>[], :script=>""}
            #
            login_viewport = {:component=>"application_viewport", :options=>{:title => "login_viewport", :location => "/software/applications/login", :style => {:float => "right", :"vertical-align" => "middle", :"border-radius" => "5px 5px 5px 5px"}}, :content=>[], :script=>""}
            switcher_viewport = {:component=>"application_viewport", :options=>{:location => "/software/applications/switcher", :style => {:float => "right", :top => "0px", :right => "0px", :width => "250px", :position => "absolute", :padding => "38px 0px 0px", :"background-color" => "transparent", :"z-index" => 1000}, :states => {:hidden => true}}, :content=>[], :script=>""}
            persisted_switcher = GxG::DB[:roles][:content].try_persist(switcher_viewport, GxG::DB[:administrator])
            persisted_switcher.set_title("switcher_menu")
            menu = {:component=>"application_viewport", :options=>{:location => "/software/applications/menu", :style => {:position => "absolute", :top => "0px", :left => "0px", :width => "250px", :padding => "38px 0px 0px", :"background-color" => "transparent", :"z-index" => 1000}, :states => {:hidden => true}}, :content=>[], :script=>""}
            persisted_menu = GxG::DB[:roles][:content].try_persist(menu, GxG::DB[:administrator])
            persisted_menu.set_title("menu")
            #
            cellone[:content] = [(image)]
            celltwo[:content] = [(login_viewport)]
            cellthree[:content] = [(switcher_image)]
            row[:content] = [(cellone), (celltwo), (cellthree)]
            table[:content] = [(row)]
            menubar[:content] = [(table)]
            page[:content] = [(menubar)]
            # return entire page
            # css: body.page { background-image: url("/images/earth-tropical-storm.jpg"); background-repeat: no-repeat; background-size: cover; }
            if GxG::VFS.exist?("/Public/www/content/pages/setup")
                GxG::VFS.rmfile("/Public/www/content/pages/setup")
            end
            # FIXME: 12 minutes to create this !!
            new_page = GxG::VFS.mkfile("/Public/www/content/pages/setup")
            new_page.get_reservation
            puts "Setting up Setup Page ..."
            page.keys.each do |the_key|
                new_page[(the_key)] = page[(the_key)]
            end
            # Gather up stray components
            new_page[:content] << persisted_menu
            new_page[:content] << persisted_switcher
            #
            puts "Setting public permissions ..."
            new_page.set_permissions(:"00000000-0000-4000-0000-000000000000", {:read => true})
            new_page.deactivate
            true
        end
        #
        def self.setup_content_dirs()
            puts "Setting up Content Directories ..."
            if GxG::VFS.exist?("/Public/www/content")
                dirs = ["/Public/www/content/pages", "/Public/www/content/themes"]
                dirs.each do |the_path|
                    if GxG::VFS.exist?(the_path)
                        the_profile = GxG::VFS.profile(the_path, {:with_credential => :"00000000-0000-4000-0000-000000000000"})
                        if the_profile
                            unless the_profile[:permissions][:effective][:read] == true
                                GxG::VFS.set_permissions(the_path, :"00000000-0000-4000-0000-000000000000", {:read => true})
                            end
                        else
                            GxG::VFS.set_permissions(the_path, :"00000000-0000-4000-0000-000000000000", {:read => true})
                        end
                    else
                        GxG::VFS.mkdir(the_path)
                        GxG::VFS.set_permissions(the_path, :"00000000-0000-4000-0000-000000000000", {:read => true})
                    end
                end
            end
            true
        end
        #
        def self.setup_software_dirs()
            puts "Setting up Software Directories ..."
            if GxG::VFS.exist?("/Public/www/software")
                dirs = ["/Public/www/software/applications", "/Public/www/software/libraries", "/Public/www/software/viewers", "/Public/www/software/editors"]
                dirs.each do |the_path|
                    if GxG::VFS.exist?(the_path)
                        the_profile = GxG::VFS.profile(the_path, {:with_credential => :"00000000-0000-4000-0000-000000000000"})
                        if the_profile
                            unless the_profile[:permissions][:effective][:read] == true
                                GxG::VFS.set_permissions(the_path, :"00000000-0000-4000-0000-000000000000", {:read => true})
                            end
                        else
                            GxG::VFS.set_permissions(the_path, :"00000000-0000-4000-0000-000000000000", {:read => true})
                        end
                    else
                        GxG::VFS.mkdir(the_path)
                        GxG::VFS.set_permissions(the_path, :"00000000-0000-4000-0000-000000000000", {:read => true})
                    end
                end
            end
            true
        end
        #
        def self.populate_new_site()
            GxGwww::Setup::setup_formats()
            GxGwww::Setup::setup_content_dirs()
            GxGwww::Setup::setup_software_dirs()
            GxGwww::Setup::setup_ace_lib()
            GxGwww::Setup::setup_css_setup()
            GxGwww::Setup::setup_css_default()
            GxGwww::Setup::setup_switcher_app()
            GxGwww::Setup::setup_menu_app()
            GxGwww::Setup::setup_login_app()
            GxGwww::Setup::setup_browser_app()
            GxGwww::Setup::setup_index_page()
            GxGwww::Setup::setup_setup_page()
            true
        end
        #
        # def self.configure_db()
        #     # Construct default configuration files:
        #     # Database Configuration:
        #     if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/databases.json")
        #       handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/databases.json", "rb")
        #       db_config = ::JSON::parse(handle.read(), {:symbolize_names => true})
        #       handle.close
        #     else
        #       # paths are REALATIVE to the system db dir
        #       db_config = {:databases => [{:url => "sqlite://default.gxg", :roles => ["users", "data", "formats", "vfs"]}, {:url => "sqlite://reference.gxg", :roles => ["reference"]}]}
        #       #
        #     end
        #     puts "Current database configuration:\n#{db_config[:databases].inspect}\n"
        #     puts "--------------------------\n"
        #     puts "0) save, 1) create new db config\n"
        #     if gets("\n").to_s.split("\n")[0].to_s.to_i == 1
        #       new_config = []
        #       editing = true
        #       while editing == true do
        #         puts "Current NEW configuration:\n#{new_config.inspect}\n"
        #         puts "--------------------------\n"
        #         puts "\nEnter a database URL (mysql://<user_id>:<password>@<host>/<database_name>) :\n"
        #         the_url = gets("\n").to_s.split("\n")[0].to_s
        #         puts "\nEnter the roles that this database serves (users,vfs, ...) comma separated, no-spaces :\n"
        #         the_roles = gets("\n").to_s.split("\n")[0].to_s.gsub(" ","").split(",")
        #         new_config << {:url => the_url, :roles => the_roles}
        #         puts "0) save as is, 1) add new db entry\n"
        #         if gets("\n").to_s.split("\n")[0].to_s.to_i == 0
        #           editing = false
        #           db_config[:databases] = new_config
        #         end
        #       end
        #     end
        #     #
        #     if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/databases.json")
        #       File.delete("#{GxG::SERVER_PATHS[:configuration]}/databases.json")
        #     end
        #     handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/databases.json","w+b", 0664)
        #     handle.write(::JSON.pretty_generate(db_config))
        #     handle.close
        #     #
        # end
        # 
        # def self.configure_vfs()
        #     # VFS Mounting Configuration:
        #     reserved_roles = ["users", "data"]
        #     if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/mounts.json")
        #       handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/mounts.json", "rb")
        #       mount_config = ::JSON::parse(handle.read(), {:symbolize_names => true})
        #       handle.close
        #     else
        #       mount_config = {:mount_points => [{:db_role => "vfs", :path => "/Storage"}, {:db_role => "reference", :path => "/Reference"}]}
        #       handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/mounts.json","w+b", 0664)
        #       handle.write(::JSON.pretty_generate(mount_config))
        #       handle.close
        #     end
        #     puts "Current VFS mount point configuration:\n#{mount_config[:mount_points].inspect}\n"
        #     puts "--------------------------\n"
        #     puts "0) save, 1) create new mount points\n"
        #     if gets("\n").to_s.split("\n")[0].to_s.to_i == 1
        #       new_config = []
        #       editing = true
        #       while editing == true do
        #         puts "Current NEW configuration:\n#{new_config.inspect}\n"
        #         puts "--------------------------\n"
        #         puts "\nEnter a: 0) DB Role mount point, 1) File System mount point\n"
        #         record = {}
        #         choice = gets("\n").to_s.split("\n")[0].to_s.to_i
        #         if choice == 0
        #           puts "\nEnter the DB Role to mount (one only):\n"
        #           the_role = gets("\n").to_s.split("\n")[0].to_s
        #           record[:db_role] = the_role
        #         else
        #           puts "\nEnter a full File System path to mount:\n"
        #           the_fs = gets("\n").to_s.split("\n")[0].to_s
        #           record[:file_system] = the_fs
        #         end
        #         puts "\nEnter a VFS path to serve as mount point\n"
        #         the_vfs = gets("\n").to_s.split("\n")[0].to_s
        #         record[:path] = the_vfs
        #         new_config << record
        #         puts "0) save as is, 1) add another mount point\n"
        #         if gets("\n").to_s.split("\n")[0].to_s.to_i == 0
        #           editing = false
        #           mount_config[:mount_points] = new_config
        #         end
        #       end
        #     end
        #     if File.exists?("#{GxG::SERVER_PATHS[:configuration]}/mounts.json")
        #       File.delete("#{GxG::SERVER_PATHS[:configuration]}/mounts.json")
        #     end
        #     handle = File.open("#{GxG::SERVER_PATHS[:configuration]}/mounts.json","w+b", 0664)
        #     handle.write(::JSON.pretty_generate(mount_config))
        #     handle.close
        #     puts "Reload environment for changes to take effect"
        #     #
        # end
    end
end
