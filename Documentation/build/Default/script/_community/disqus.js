var Innovasys;
(function (Innovasys) {
    var Community;
    (function (Community) {
        var Common = (function () {
            function Common() {
            }
            /** Inserts a script into the current page, optionally calling a function when the script has loaded */
            Common.insertScript = function (url, id, onLoad) {
                if (id === void 0) { id = null; }
                if (onLoad === void 0) { onLoad = null; }
                if (id != null && document.getElementById(id) != null) {
                    // Script already exists
                    return;
                }
                var existingScript = document.getElementsByTagName("script")[0];
                var newScript = document.createElement("script");
                newScript.id = id;
                newScript.src = url;
                if (onLoad != null) {
                    if (newScript.addEventListener) {
                        newScript.addEventListener("load", onLoad, false);
                    }
                    else if (newScript.readyState) {
                        newScript.onreadystatechange = function () {
                            if (onLoad != null && (newScript.readyState == "loaded" || newScript.readyState == "complete")) {
                                onLoad();
                                onLoad = null;
                            }
                        };
                    }
                }
                if (existingScript != null) {
                    existingScript.parentNode.insertBefore(newScript, existingScript);
                }
                else {
                    document.getElementsByTagName("body")[0].appendChild(newScript);
                }
            };
            /** Returns the footer div for the current page. If the footer div isn't found, the body element is returned instead */
            Common.getFooterDiv = function () {
                // Find the footer div
                var footerDiv = document.getElementById("i-footer-content");
                if (footerDiv == null) {
                    footerDiv = document.getElementById("FooterContent");
                }
                if (footerDiv == null) {
                    // Older templates, #pagefooter
                    footerDiv = document.getElementById("pagefooter");
                    if (footerDiv == null) {
                        // No footer section, append to body
                        footerDiv = document.getElementsByTagName('body')[0];
                    }
                }
                return footerDiv;
            };
            /** Returns true if the current location protocol is one of the passed arguments */
            Common.isSupportedProtocol = function () {
                var supportedProtocols = [];
                for (var _i = 0; _i < arguments.length; _i++) {
                    supportedProtocols[_i - 0] = arguments[_i];
                }
                for (var i = 0, c = supportedProtocols.length; i < c; i++) {
                    var supportedProtocol = supportedProtocols[i];
                    if (supportedProtocol === location.protocol) {
                        return true;
                    }
                }
                return false;
            };
            /** Writes a standardized message banner for the passed heading and message text */
            Common.writeMessageBanner = function (container, headingText, messageText, className) {
                if (className === void 0) { className = null; }
                if (container == null) {
                    container = Common.getFooterDiv();
                }
                var messageDiv = document.createElement("DIV");
                messageDiv.className = className;
                messageDiv.style.cssText = "background: #f0f0f0; padding: 1px 4px 8px 12px;";
                messageDiv.innerHTML = "<h2>" + headingText + "</h2><p>" + messageText + "</p>";
                container.appendChild(messageDiv);
            };
            /** Writes a message banner identifying that the current protocol is not supported */
            Common.writeUnsupportedProtocolMessage = function (container, providerName) {
                var protocolCaption = Common.getProtocolCaption();
                Common.writeMessageBanner(container, providerName + " not supported in " + protocolCaption, providerName + " are not supported in " + protocolCaption + ". This functionality will operate correctly when this content is viewed from a web server.", "community-unsupported-protocol-container");
            };
            /** Returns a friendly name for the current location protocol */
            Common.getProtocolCaption = function () {
                switch (location.protocol) {
                    case "file:":
                        return "local content";
                    case "ms-its:":
                        return "CHM files";
                    default:
                        return location.protocol + " content";
                }
            };
            /** Writes a container DIV and then invokes easyXDM to load the passed communityUrl in an IFRAME */
            Common.writeRemoteCommentsContent = function (communityUrl) {
                var footerDiv = Innovasys.Community.Common.getFooterDiv();
                var commentsDiv = document.createElement("DIV");
                commentsDiv.id = "i-comments-container";
                footerDiv.appendChild(commentsDiv);
                if (typeof easyXDM === "undefined") {
                    // easyXDM not loaded, load it now and then initialize
                    var baseUrl = communityUrl.substring(0, communityUrl.lastIndexOf("/"));
                    var easyXDMUrl = baseUrl + "/easyXDM.js";
                    Common.insertScript(easyXDMUrl, "easyxdm-script", function () {
                        Common.initializeRemoteContent(communityUrl, "i-comments-container");
                    });
                }
                else {
                    Common.initializeRemoteContent(communityUrl, "i-comments-container");
                }
            };
            /** Initialized easyXDM to load the passed communityUrl in an IFRAME */
            Common.initializeRemoteContent = function (remoteUrl, containerElementId) {
                new easyXDM.Socket({
                    remote: remoteUrl,
                    container: document.getElementById(containerElementId),
                    onMessage: function (message, origin) {
                        // Size to height and set to 100% width
                        this.container.getElementsByTagName("iframe")[0].style.height = message + "px";
                        this.container.getElementsByTagName("iframe")[0].style.width = "100%";
                    }
                });
            };
            /** Writes remote provider content if it is available, falling back to specific failure message banner if not */
            Common.writeRemoteCommentsContentIfAvailable = function (pingImageUrl, communityUrl, failureHeadingText, failureMessageText, failureClassName, failurePlaceholderContainer) {
                if (failureClassName === void 0) { failureClassName = null; }
                if (failurePlaceholderContainer === void 0) { failurePlaceholderContainer = null; }
                if (failurePlaceholderContainer == null) {
                    failurePlaceholderContainer = Common.getFooterDiv();
                }
                var image = new Image;
                image.onload = function () {
                    if ('naturalHeight' in this) {
                        if (this.naturalHeight + this.naturalWidth === 0) {
                            // Fail, write the placeholder
                            Common.writeMessageBanner(failurePlaceholderContainer, failureHeadingText, failureMessageText, failureClassName);
                            return;
                        }
                    }
                    else if (this.width + this.height == 0) {
                        // Fail, write the placeholder
                        Common.writeMessageBanner(failurePlaceholderContainer, failureHeadingText, failureMessageText, failureClassName);
                        return;
                    }
                    // Success, invoke the callback
                    Common.writeRemoteCommentsContent(communityUrl);
                };
                image.onerror = function () {
                    // Fail, write the placeholder
                    Common.writeMessageBanner(failurePlaceholderContainer, failureHeadingText, failureMessageText, failureClassName);
                };
                image.src = pingImageUrl;
            };
            /** Writes remote provider content if it is available, falling back to a standard message if not */
            Common.writeRemoteProviderContentIfAvailable = function (providerName, communityUrl, failurePlaceholderContainer) {
                if (failurePlaceholderContainer === void 0) { failurePlaceholderContainer = null; }
                var baseUrl = communityUrl.substring(0, communityUrl.lastIndexOf("/"));
                var pingImageUrl = baseUrl + "/" + providerName.toLowerCase() + ".png";
                Common.writeRemoteCommentsContentIfAvailable(pingImageUrl, communityUrl, providerName + " Comments Not Available", providerName + " comments are not available as the content has not yet been published or is not accessible.", "community-content-not-available");
            };
            return Common;
        }());
        Community.Common = Common;
    })(Community = Innovasys.Community || (Innovasys.Community = {}));
})(Innovasys || (Innovasys = {}));
//# sourceMappingURL=common.js.mapvar Innovasys;
(function (Innovasys) {
    var Community;
    (function (Community) {
        var Disqus = (function () {
            function Disqus() {
            }
            Disqus.initializePage = function (shortName, title, url, identifier, remoteUrl, writeUnsupportedProtocolMessage) {
                if (remoteUrl === void 0) { remoteUrl = null; }
                if (writeUnsupportedProtocolMessage === void 0) { writeUnsupportedProtocolMessage = true; }
                // Find the footer div
                var footerDiv = Innovasys.Community.Common.getFooterDiv();
                // Check that we aren't running in an unsupported protocol (e.g. CHM or file:)
                if (!Innovasys.Community.Common.isSupportedProtocol("http:", "https:")) {
                    if (remoteUrl != null && Innovasys.Community.Common.isSupportedProtocol("file:")) {
                        Innovasys.Community.Common.writeRemoteProviderContentIfAvailable("Disqus", remoteUrl);
                    }
                    else {
                        if (writeUnsupportedProtocolMessage) {
                            Innovasys.Community.Common.writeUnsupportedProtocolMessage(footerDiv, "Disqus Comments");
                        }
                    }
                    return;
                }
                // Set configuration variables
                window.disqus_shortname = shortName;
                window.disqus_url = url;
                window.disqus_title = title;
                window.disqus_identifier = identifier;
                // Create the comments container div
                var commentsDiv = document.createElement("div");
                commentsDiv.id = "disqus_thread";
                // Append to footer (#FooterContent in current templates)
                footerDiv.appendChild(commentsDiv);
                // Add the embed script
                Innovasys.Community.Common.insertScript("//" + shortName + ".disqus.com/embed.js", "disqus-script");
            };
            return Disqus;
        }());
        Community.Disqus = Disqus;
    })(Community = Innovasys.Community || (Innovasys.Community = {}));
})(Innovasys || (Innovasys = {}));
//# sourceMappingURL=disqus.js.map