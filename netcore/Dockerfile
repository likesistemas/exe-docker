ARG CERTIFICATE_PASSWORD=123456

FROM likesistemas/exe-sign:latest as sign
ARG CERTIFICATE_PASSWORD
ENV CERT_PASSWORD=${CERTIFICATE_PASSWORD}

FROM mcr.microsoft.com/dotnet/sdk:5.0 as project
WORKDIR /work/
COPY exe-jar/Program.cs exe-jar/favicon.ico exe-jar/exe-jar.csproj ./
RUN dotnet restore

FROM project as exe-x86
RUN dotnet publish -c Release -r win-x86 -p:PublishSingleFile=true --self-contained true \
 && cp ./bin/Release/net5.0/win-x86/publish/* ./bin/ \
 && rm -Rf ./bin/Release/

FROM sign as sign-x86
COPY --from=exe-x86 /work/bin/exe-jar.exe app.exe
RUN sign

FROM debian:10-slim
WORKDIR /work/
COPY --from=exe-x86 /work/bin/* ./
COPY --from=sign-x86 /work/app_signed.exe app-x86_signed.exe
CMD cp -Rfv /work/* /output/