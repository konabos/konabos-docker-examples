# escape=`

ARG BASE_IMAGE
ARG SPS_IMAGE
ARG SPE_IMAGE
ARG TOOLING_IMAGE

FROM ${TOOLING_IMAGE} as tooling
FROM ${SPS_IMAGE} as sps
FROM ${SPE_IMAGE} as spe
FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Copy development tools and entrypoint
COPY --from=tooling \tools\ \tools\

COPY ./transforms C:\transforms
RUN C:\tools\scripts\Invoke-XdtTransform.ps1 -Path C:\inetpub\wwwroot\App_Config\ConnectionStrings.config -XdtPath C:\transforms\connectionstrings.xdt.config

COPY ./patch C:\inetpub\wwwroot\App_Config\Include\Foundation\
WORKDIR C:\inetpub\wwwroot

# Add SPE module
COPY --from=spe \module\cm\content .\
# RUN Rename-Item -Path "c:\inetpub\wwwroot\App_Config\Include\Spe\Spe.IdentityServer.config.disabled" -NewName "Spe.IdentityServer.config"

COPY --from=sps \module\cm\content .\

# Disable Identity Server
RUN Copy-Item -Path 'C:\\inetpub\\wwwroot\\App_Config\\Include\\Examples\\Sitecore.Owin.Authentication.IdentityServer.Disabler.config.example' `
              -Destination 'C:\\inetpub\\wwwroot\\App_Config\\Include\\Sitecore.Owin.Authentication.IdentityServer.Disabler.config';

RUN Copy-Item -Path C:\inetpub\wwwroot\App_Data\items\Web -Destination C:\inetpub\wwwroot\App_Data\items\Preview -Recurse; `
    Move-Item -Path C:\inetpub\wwwroot\App_Data\items\Preview\items.web.dat -Destination C:\inetpub\wwwroot\App_Data\items\Preview\items.preview.dat