<!DOCTYPE html>
<html lang="en">
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"
            <meta http-equiv="X-UA-Compatible" content="image"
            <title>Document</title>
    </head>
    <body>
        {{ Auth::id() }}
        @vite('resources/js/app.js')
</body>
<script>
setTimeout(() => {

    window.Echo.private('private-channel.user.{{ Auth::id() }}')
        .listen('PrivateEvent', (e)=>{
            console.log(e);
        })
}, 200);

//     window.Echo.channel('testChannel')
//         .listen('testingEvent', (e)=>{
//             console.log(e);
//         })
// }, 200);
</script>
</html>
