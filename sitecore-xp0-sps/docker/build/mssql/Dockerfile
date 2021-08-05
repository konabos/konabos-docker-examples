# escape=`

ARG BASE_IMAGE
ARG SPE_IMAGE
ARG SPS_IMAGE

FROM ${SPS_IMAGE} as sps
FROM ${SPE_IMAGE} as spe
FROM ${BASE_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Add SPE module
COPY --from=spe \module\db \spe_data
RUN C:\DeployDatabases.ps1 -ResourcesDirectory C:\spe_data; `
    Remove-Item -Path C:\spe_data -Recurse -Force;

COPY --from=sps \module\db \sps_data
RUN C:\DeployDatabases.ps1 -ResourcesDirectory C:\sps_data; `
    Remove-Item -Path C:\sps_data -Recurse -Force;

RUN Copy-Item -Path C:\install\Sitecore.Web_Primary.mdf -Destination C:\install\Sitecore.Preview_Primary.mdf; `
    Copy-Item -Path C:\install\Sitecore.Web_Primary.ldf -Destination C:\install\Sitecore.Preview_Primary.ldf;  