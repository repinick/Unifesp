import Image from 'next/image';

export default function Header() {
    return (
        <div>
            <div className="bg-green-900 flex flex-col items-center justify-center py-2.5">
                <Image 
                    src='/images/unifesp-logo.png'
                    width={150}
                    height={150}
                    alt="Logo Unifesp" 
                />
                <h1 className="text-white font-serif mt-2 text-center text-xl" style={{ fontFamily: 'Times New Roman, serif' }}>
                    EGRESSOS
                </h1>
            </div>
            <div className="bg-white h-1"></div>
        </div>
    )
}